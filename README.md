# PHPSession
[![Build Status](https://travis-ci.org/Shinpeim/ruby_php_session.png?branch=master)](https://travis-ci.org/Shinpeim/ruby_php_session)
[![Code Climate](https://codeclimate.com/github/Shinpeim/ruby_php_session.png)](https://codeclimate.com/github/Shinpeim/ruby_php_session)

## Description
PHPSession is a php session reader/writer.

### Mapping between ruby and PHP

When decoding php session data to ruby objects,

* Associative arrays in PHP is mapped to hashes in ruby.
* Objects in PHP is mapped to instances of Struct::ClassName in ruby.

When encoding ruby objects to php session data,

* Strings or symbols in ruby is mapped to strings in PHP.
* Instances of Struct::ClassName in ruby is mapped to a objects in PHP.
* Arrays in ruby is mapped to a associative arrays which's keys are integer in PHP.
* Hashes in ruby is mapped to a associative arrays which's keys are string in PHP.

### Session store engines are pluggable

By default, PHPSession use file session store, which is compatible with PHP session file.

You can use your own session store like bellow.

First, develop your own store_engine.

```ruby
# lib_path/php_session/store_engine/custom.rb
class PHPSession
  module StoreEngine
    class File
      def initialize(option)
        # option passed to PHPSession constractor
        @option = option
      end

      def load(session_id)
        # load php-style serialized session data from your favorite storage
        # and return that
      end

      def save(session_id, serialized_session)
        # save php-style serialized session data to your favorite storage
      end

      def destroy(session_id)
        # delete session_data from your favorite storage
      end
      
      def exists?(session_id)
        # return whether the session_id already exists in your storage
      end
    end
  end
end

# register store engine name and store engine class
PHPSession.register_store_engine(:custom, PHPSession::StoreEngine::Custom)
```

And then, assingn engine name to option[:store_engine] passed to PHPSession constractor

```ruby
option = {
  :external_encoding => "EUC-JP",
  :internal_encoding => "UTF-8",
  :encoding_option   => {:undef => :replace},
  :session_file_dir => @session_file[:dir_name],
}
session = PHPSession.new(option)
```

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
```ruby
# initialize
option = {
  :internal_encoding => "UTF-8",  # value will be decoded as UTF-8
  :external_encoding => "EUC-JP", # encoding of sesion file is EUC-JP
  :encoding_option   => {:undef => :replace} # passed to String#encode

  :store_engine      => :file,
  :session_file_dir  => "/path/to/session_file_dir" # needed when the store_engine is :file
}
# option's default values are
# :internal_encoding => Encoding.default_internal_encoding
# :external_encoding => Encoding.default_external_encoding
# :encoding_option   => {}
# :store_engine      => :file,
    
session = PHPSession.new(option)

# load session data
data = session.load(session_id)

data.is_a? Hash # => true

# save session
session.commit(session_id, data)

# delete session
session.destroy(session_id)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
