# -*- coding: utf-8 -*-
require "php_session/version"
require "php_session/errors"
require "php_session/decoder"
require "php_session/encoder"
require "php_session/store_engine/file"

class PHPSession
  attr_reader :data

  def self.register_store_engine(engine_name, klass)
    @engines ||= {}
    @engines[engine_name] = klass
  end

  def self.store_engine_class_of(engine_name)
    store_engine = @engines[engine_name]
    raise PHPSession::Errors, "unknown sotre engine: #{engine_name}" unless store_engine

    store_engine
  end

  def initialize(option = {})
    default_option = {
      :store_engine => :file,

      :internal_encoding => Encoding.default_internal,
      :external_encoding => Encoding.default_external,
      :encoding_option => {},
    }
    @option = default_option.merge(option)

    store_engine_class = self.class.store_engine_class_of(@option[:store_engine])

    @store_engine = store_engine_class.new(@option)
  end

  def load(session_id)
    serialized_session = @store_engine.load(session_id)
    Decoder.decode(serialized_session, @option[:internal_encoding], @option[:encoding_option]) || {}
  end

  def destroy(session_id)
    @store_engine.destroy(session_id)
  end

  def save(session_id, data)
    serialized_session = Encoder.encode(data, @option[:external_encoding], @option[:encoding_option])
    @store_engine.save(session_id, serialized_session)
  end
end

PHPSession.register_store_engine(:file, PHPSession::StoreEngine::File)
