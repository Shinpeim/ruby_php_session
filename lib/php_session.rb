require "php_session/version"
require "php_session/errors"
require "php_session/decoder"
require "php_session/encoder"

class PHPSession
  def initialize(session_dir, session_id)
    @session_dir = File.expand_path(session_dir)
    set_session_id(session_id)

    @file = File.open(file_path, File::CREAT|File::RDWR)
    unless @file
      raise PHPSession::Errors, "can't open session file"
    end

    unless @file.flock(File::LOCK_EX)
      raise PHPSession::Errors, "can't obtain lock of session file"
    end

    @session = Decoder.decode(@file.read) || {}
    @file.rewind
  end

  def [](key)
    @session[key]
  end

  def []=(key, value)
    @session[key] = value
  end

  def destroy
    @session = {}
    @file.truncate(0)
    ensure_file_closed
    File.delete(file_path)
  end

  def commit
    @file.truncate(0)
    @file.write(Encoder.encode(@session))
    ensure_file_closed
  end

  def ensure_file_closed
    @file.close unless @file.closed?
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
