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

    @file = nil
  end

  def load(session_id)
    set_session_id(session_id)
    @file = File.open(file_path, File::CREAT|File::RDWR)

    unless @file.flock(File::LOCK_EX)
      raise PHPSession::Errors, "can't obtain lock of session file"
    end

    # set internal_encoding to nil to avoid encoding conversion
    @file.set_encoding(@option[:external_encoding], nil)
    data = Decoder.decode(@file.read, @option[:internal_encoding], @option[:encoding_option]) || {}
    @file.rewind
    data
  end

  def loaded?
    ! @file.nil?
  end

  def destroy
    if @file && ! @file.closed?
      @file.truncate(0)
    end
    ensure_file_closed
    File.delete(file_path)
  rescue Errno::ENOENT => e
    # file already deleted
  end

  def commit(data)
    self.load(@session_id) unless @file
    @file.truncate(0)
    @file.write(Encoder.encode(data, @option[:external_encoding], @option[:encoding_option]))
    ensure_file_closed
  end

  def ensure_file_closed
    if @file && ! @file.closed?
      @file.close
    end
  end

  private

  def set_session_id(session_id)
    @session_id = session_id
    raise Errors::SecurityError, "directory traversal detected" unless file_path.index(@session_dir) == 0
  end

  def file_path
    File.expand_path(File.join(@session_dir, "sess_#{@session_id}"))
  end
end
