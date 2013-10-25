# -*- coding: utf-8 -*-
class PHPSession
  class Encoder
    attr_reader :encoding, :encoding_option
    def self.encode(hash, encoding = nil, encoding_option = {})
      encoding = Encoding.default_external if encoding.nil?
      self.new(encoding, encoding_option).encode(hash)
    end

    def initialize(encoding, encoding_option)
      @encoding = encoding
      @encoding_option = encoding_option
    end

    def encode(hash)
      serialized = hash.map do|k,v|
        "#{k.to_s}|#{serialize(v)}"
      end
      serialized.join
    end

    def serialize(value)
      get_serializer(value.class).serialize(value)
    end

    private

    def get_serializer(klass)
      case
      when klass <= String || klass <= Symbol
        StringSerializer.new(self)
      when klass <= Integer
        IntegerSerializer.new(self)
      when klass <= Float
        FloatSerializer.new(self)
      when klass <= NilClass
        NilSerializer.new(self)
      when klass <= TrueClass || klass <= FalseClass
        BooleanSerializer.new(self)
      when klass <= Hash
        HashSerializer.new(self)
      when klass <= Array
        ArraySerializer.new(self)
      when klass <= Struct
        StructSerializer.new(self)
      else
        raise Errors::EncodeError, "unsupported class:#{klass.to_s} is passed."
      end
    end

    class Serializer
      def initialize(encoder)
        @encoder = encoder
      end
    end
    class StringSerializer < Serializer
      def serialize(value)
        value = value.to_s
        # encode here for valid bytesize
        s = value.encode(@encoder.encoding, @encoder.encoding_option)
        %|s:#{s.bytesize}:"#{s}";|
      end
    end
    class IntegerSerializer < Serializer
      def serialize(value)
        %|i:#{value};|
      end
    end
    class FloatSerializer < Serializer
      def serialize(value)
        %|d:#{value};|
      end
    end
    class NilSerializer < Serializer
      def serialize(value)
        %|N;|
      end
    end
    class BooleanSerializer < Serializer
      def serialize(value)
        %|b:#{value ? 1 : 0};|
      end
    end
    class HashSerializer < Serializer
      def serialize(value)
        serialized_values = value.map do |k, v|
          [@encoder.serialize(k), @encoder.serialize(v)]
        end
        %|a:#{value.size}:{#{serialized_values.flatten.join}}|
      end
    end
    class ArraySerializer < Serializer
      def serialize(value)
        key_values = value.map.with_index{|el, i| [i, el]}
        hash = Hash[key_values]
        HashSerializer.new(@encoder).serialize(hash)
      end
    end
    class StructSerializer < Serializer
      def serialize(value)
        key_values = value.members.zip(value.values)
        serialized_key_values = key_values.map do |kv|
          kv.map {|el| @encoder.serialize(el)}
        end
        class_name = value.class.to_s.gsub(/^Struct::/,'')
        %|o:#{class_name.bytesize}:"#{class_name}":#{key_values.size}:{#{serialized_key_values.flatten.join}}|
      end
    end
  end
end
