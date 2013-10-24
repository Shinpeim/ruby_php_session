# -*- coding: utf-8 -*-
require "php_session/version"
require "php_session/errors"
require "php_session/decoder"
require "php_session/encoder"

class PHPSession
  attr_reader :data
  def initialize(session_dir, session_id)
    @session_dir = File.expand_path(session_dir)
    set_session_id(session_id)

    @file = nil
  end

  def load
    @file = File.open(file_path, File::CREAT|File::RDWR)

    unless @file.flock(File::LOCK_EX)
      raise PHPSession::Errors, "can't obtain lock of session file"
    end

    data = Decoder.decode(@file.read) || {}
    @file.rewind
    data
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
    @file.truncate(0)
    @file.write(Encoder.encode(data))
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
