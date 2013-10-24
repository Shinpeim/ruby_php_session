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
