# -*- coding: utf-8 -*-
require "php_session/version"
require "php_session/errors"
require "php_session/decoder"
require "php_session/encoder"

class PHPSession
  attr_reader :data
  def initialize(session_dir, option = {})
    default_option = {
      :internal_encoding => Encoding.default_internal,
      :external_encoding => Encoding.default_external,
      :encoding_option => {},
    }
    @option = default_option.merge(option)
    @session_dir = File.expand_path(session_dir)
  end

  def load(session_id)
    with_lock(file_path(session_id)) do |f|
     # set internal_encoding to nil to avoid encoding conversion
      f.set_encoding(@option[:external_encoding], nil)
      Decoder.decode(f.read, @option[:internal_encoding], @option[:encoding_option]) || {}
    end
  end

  def destroy(session_id)
    File.delete(file_path(session_id))
  rescue Errno::ENOENT => e
    # file already deleted
  end

  def save(session_id, data)
    with_lock(file_path(session_id)) do |f|
      f.truncate(0)
      f.write(Encoder.encode(data, @option[:external_encoding], @option[:encoding_option]))
    end
  end

  private

  def with_lock(file_path)
    File.open(file_path, File::CREAT|File::RDWR) do |f|
      unless f.flock(File::LOCK_EX)
        raise PHPSession::Errors, "can't obtain lock of session file"
      end
      yield(f)
    end
  end

  def set_session_id(session_id)
    @session_id = session_id
    raise Errors::SecurityError, "directory traversal detected" unless file_path.index(@session_dir) == 0
  end

  def file_path(session_id)
    path = File.expand_path(File.join(@session_dir, "sess_#{session_id}"))
    raise Errors::SecurityError, "directory traversal detected" unless path.index(@session_dir) == 0
    path
  end
end
