class PHPSession
  class Encoder
    def self.encode(hash)
      serialized = hash.map do|k,v|
        "#{k}|#{serialize(v)}"
      end
      serialized.join
    end

    private

    def self.serialize(value)
      get_serializer(value.class).serialize(value)
    end

    def self.get_serializer(klass)
      case
      when klass <= String || klass <= Symbol
        StringSerializer
      when klass <= Integer
        IntegerSerializer
      when klass <= Float
        FloatSerializer
      when klass <= NilClass
        NilSerializer
      when klass <= TrueClass || klass <= FalseClass
        BooleanSerializer
      when klass <= Hash
        HashSerializer
      when klass <= Array
        ArraySerializer
      when klass <= Struct
        StructSerializer
      end
    end

   class StringSerializer
      def self.serialize(value)
        s = value.to_s
        %|s:#{s.bytesize}:"#{s}";|
      end
    end
    class IntegerSerializer
      def self.serialize(value)
        %|i:#{value};|
      end
    end
    class FloatSerializer
      def self.serialize(value)
        %|d:#{value};|
      end
    end
    class NilSerializer
      def self.serialize(value)
        %|N;|
      end
    end
    class BooleanSerializer
      def self.serialize(value)
        %|b:#{value ? 1 : 0};|
      end
    end
    class HashSerializer
      def self.serialize(value)
        serialized_values = value.map do |k, v|
          [Encoder.serialize(k), Encoder.serialize(v)]
        end
        %|a:#{value.size}:{#{serialized_values.flatten.join}}|
      end
    end
    class ArraySerializer
      def self.serialize(value)
        key_values = value.map.with_index{|el, i| [i, el]}
        hash = Hash[key_values]
        HashSerializer.serialize(hash)
      end
    end
    class StructSerializer
      def self.serialize(value)
        key_values = value.members.zip(value.values)
        serialized_key_values = key_values.map do |kv|
          kv.map {|el| Encoder.serialize(el)}
        end
        class_name = value.class.to_s.gsub(/^Struct::/,'')
        %|o:#{class_name.bytesize}:"#{class_name}":#{key_values.size}:{#{serialized_key_values.flatten.join}}|
      end
    end
  end
end
