# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'php_session/version'

Gem::Specification.new do |spec|
  spec.name          = "php_session"
  spec.version       = PHPSession::VERSION
  spec.authors       = ["Shinpei Maruyama"]
  spec.email         = ["shinpeim@gmail.com"]
  spec.description   = %q{php session reader/writer}
  spec.summary       = %q{php_session is a php session file reader/writer. Multibyte string and exclusive control is supported}
  spec.homepage      = "https://github.com/Shinpeim/ruby_php_session"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
