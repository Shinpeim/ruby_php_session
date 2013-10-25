# PHPSession
[![Build Status](https://travis-ci.org/Shinpeim/ruby_php_session.png?branch=master)](https://travis-ci.org/Shinpeim/ruby_php_session)
[![Code Climate](https://codeclimate.com/github/Shinpeim/ruby_php_session.png)](https://codeclimate.com/github/Shinpeim/ruby_php_session)
## Description
PHPSession is a php session file reader/writer. Multibyte string and exclusive control are supported.

When decoding php session data to ruby objects,

* Associative arrays in PHP is mapped to hashes in ruby.
* Objects in PHP is mapped to instances of Struct::ClassName in ruby.

When encoding ruby objects to php session data,

* Strings or symbols in ruby is mapped to strings in PHP.
* Instances of Struct::ClassName in ruby is mapped to a objects in PHP.
* Arrays in ruby is mapped to a associative arrays which's keys are integer in PHP.
* Hashes in ruby is mapped to a associative arrays which's keys are string in PHP.

### Multibyte support

Passing option to PHPSession.new, you can handle encodings.

Options are:

* :internal_encoding

    When this value is not nil, Session decoder tries to
    encode string values into this encoding.

    For a instance, if your php session file written in EUC-JP and you
    like to handle string as UTF-8 in Ruby, you should set :internal_encoding
    as "UTF-8" and :external_encoding as "EUC-JP".

    Default value is Encoding.default_internal.

* :external_encoding

    This value should be same as php session file's encoding.
    Encoder tries to encode string values into this encoding.

    Default value is Encoding.default_external.

* :encoding_option

    This value is passed to String#encode.


## Installation

Add this line to your application's Gemfile:

    gem 'php_session'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install php_session

## Usage
    # initialize
    option = {
        :internal_encoding => "UTF-8",  # value will be decoded as UTF-8
        :external_encoding => "EUC-JP", # encoding of sesion file is EUC-JP
        :encoding_option   => {:undef => :replace} # passed to String#encode
    }
    # option's default values are
    # :internal_encoding => Encoding.default_internal_encoding
    # :external_encoding => Encoding.default_external_encoding
    # :encoding_option   => {}
    session = PHPSession.new(session_file_dir, option)

    begin
      # load session data from file and obtain a lock
      data = session.load(session_id)

      data.is_a? Hash # => true

      # save session and release the lock
      session.commit(data)

      # delete session file and release the lock
      session.destroy
    ensure
      # please ensure that the lock is released and the file is closed.
      session.ensure_file_closed
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
