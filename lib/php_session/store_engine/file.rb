# -*- coding: utf-8 -*-
class PHPSession
  module StoreEngine
    class File
      def initialize(option)
        if ! option[:session_file_dir]
          raise PHPSession::Errors::ParameterError , "option[:session_dir] is required"
        end

        @option = option
      end

      def load(session_id)
        serialized_session = with_lock(file_path(session_id)) do |f|
          # set internal_encoding to nil to avoid encoding conversion
          f.set_encoding(@option[:external_encoding], nil)
          f.read
        end

        serialized_session
      end

      def save(session_id, serialized_session)
        with_lock(file_path(session_id)) do |f|
          f.truncate(0)
          f.write(serialized_session)
        end
      end

      def destroy(session_id)
        ::File.delete(file_path(session_id))
      rescue Errno::ENOENT
        # file already deleted
      end

      private

      def with_lock(file_path)
        mode = ::File::CREAT|::File::RDWR
        ::File.open(file_path, mode) do |f|
          unless f.flock(::File::LOCK_EX)
            raise PHPSession::Errors, "can't obtain lock of session file"
          end
          yield(f)
        end
      end

      def file_path(session_id)
        path = ::File.expand_path(::File.join(@option[:session_file_dir], "sess_#{session_id}"))
        raise Errors::SecurityError, "directory traversal detected" unless path.index(@option[:session_file_dir]) == 0
        path
      end
    end
  end
end
