# -*- coding: utf-8 -*-
require 'php_session'
require 'tempfile'

def create_dummy_session_file(text)
  file_path = Tempfile.open(["sess_", ""]) {|f|
    f.write(text)
    f.path
  }
  dirname = File.dirname(file_path)
  session_id = File.basename(file_path).gsub(/^sess_/,'')

  {:file_path => file_path, :dir_name => dirname, :session_id => session_id}
end

def with_encoding(internal, external)
  default_internal_was = Encoding.default_internal
  default_external_was = Encoding.default_external

  Encoding.default_external = external
  Encoding.default_internal = internal

  begin
    yield
  ensure
    Encoding.default_external = default_external_was
    Encoding.default_internal = default_internal_was
  end
end
