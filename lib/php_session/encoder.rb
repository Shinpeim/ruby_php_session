module PHPSession
  class Encoder
    def self.encode(hash)
      serialized = hash.map do|k,v|
        "#{k}|#{serialize(v)}"
      end
      serialized.join
    end

    private

    def self.serialize(value)
      get_serializer(value).new(value).serialize
    end

    def self.get_serializer(value)
      case
      when value.is_a?(String) || value.is_a?(Symbol)
        StringSerializer
      when value.is_a?(Integer)
        IntegerSerializer
      when value.is_a?(Float)
        FloatSerializer
      when value.nil?
        NilSerializer
      when value.is_a?(TrueClass) || value.is_a?(FalseClass)
        BooleanSerializer
      when value.is_a?(Hash)
        HashSerializer
      when value.is_a?(Array)
        ArraySerializer
      when value.is_a?(Struct)
        StructSerializer
      end
    end

    class Serializer
      def initialize(value)
        @value = value
      end
    end
    class StringSerializer < Serializer
      def serialize
        s = @value.to_s
        %|s:#{s.bytesize}:"#{s}";|
      end
    end
    class IntegerSerializer < Serializer
      def serialize
        %|i:#{@value};|
      end
    end
    class FloatSerializer < Serializer
      def serialize
        %|d:#{@value};|
      end
    end
    class NilSerializer < Serializer
      def serialize
        %|N;|
      end
    end
    class BooleanSerializer < Serializer
      def serialize
        %|b:#{@value ? 1 : 0};|
      end
    end
    class HashSerializer < Serializer
      def serialize
        serialized_values = @value.map do |k, v|
          [Encoder.serialize(k), Encoder.serialize(v)]
        end
        %|a:#{@value.size}:{#{serialized_values.flatten.join}}|
      end
    end
    class ArraySerializer < Serializer
      def serialize
        key_values = @value.map.with_index{|el, i| [i, el]}
        hash = Hash[key_values]
        HashSerializer.new(hash).serialize
      end
    end
    class StructSerializer < Serializer
      def serialize
        key_values = @value.members.zip(@value.values)
        serialized_key_values = key_values.map do |kv|
          kv.map {|el| Encoder.serialize(el)}
        end
        class_name = @value.class.to_s.gsub(/^Struct::/,'')
        %|o:#{class_name.bytesize}:"#{class_name}":#{key_values.size}:{#{serialized_key_values.flatten.join}}|
      end
    end
  end
end
