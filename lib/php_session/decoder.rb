# -*- coding: utf-8 -*-
class PHPSession
  class Decoder
    attr_accessor :buffer, :state, :stack, :array
    attr_reader :encoding, :encoding_option

    def self.decode(string, encoding = nil, encoding_option = {})
      if string.nil?
        string = ""
      end
      string.chomp!
      self.new(string, encoding, encoding_option).decode
    end

    def initialize(string, encoding, encoding_option)
      @encoding = encoding
      @encoding_option = encoding_option
      @buffer = string
      @data = {}
      @state = State::VarName
      @stack = []
      @array = [] # array of array
    end

    def decode
      loop do
        break if @buffer.size == 0
        @state.parse(self)
      end
      @data
    end

    def start_array(length, klass = nil)
      # [length, comsumed?, class]
      @array.unshift({
        :length => length,
        :consumed_count => 0,
        :klass => klass
      })
    end
    def elements_count
      @array[0][:length]
    end
    def in_array
      @array.size > 0
    end
    def consume_array
      @array[0][:consumed_count] += 1
    end
    def finished_array
      @array[0][:length] * 2 == @array[0][:consumed_count]
    end

    def extract_stack(count)
      poped = @stack[(@stack.size - count) .. -1]
      @stack = @stack.slice(0, @stack.size - count)
      poped
    end

    def process_empty_array_value
      array_which_finished  = @array.shift

      klass  = array_which_finished[:klass];
      if klass
        struct = define_or_find_struct(klass, [])
        process_value(struct.new)
      else
        process_value({})
      end
      @state = State::ArrayEnd
    end
    def process_value(value)
      if in_array
        @stack.push(value)
        consume_array

        if finished_array
          array_which_finished  = @array.shift
          key_values_array = extract_stack(array_which_finished[:length] * 2)
          key_values = key_values_array.group_by.with_index{|el, i| i%2 == 0 ? :key : :value}

          klass  = array_which_finished[:klass];
          if klass
            struct = define_or_find_struct(klass, key_values[:key])
            process_value(struct.new(*key_values[:value]))
            @state = State::ArrayEnd
            @state.parse(self)
          else
            hash = {}
            key_values_array.each_slice(2) do |kv|
              hash[kv[0]] = kv[1]
            end
            process_value(hash)

            @state = State::ArrayEnd
            @state.parse(self)
          end
        else
          @state = State::VarType
        end
      else
        varname = @stack.pop;
        @data[varname] = value;
        @state = State::VarName
      end
    end

    private

    def define_or_find_struct(name, properties)
      if Struct.const_defined?(name)
        struct = Struct.const_get(name)
        if struct.members.sort != properties.map(&:to_sym).sort
          raise Errors::ParseError, "objects properties don't match with the other object which has same class"
        end
      else
        struct = Struct.new(name, *properties)
      end
      struct
    end

    module State
      class VarName
        def self.parse(decoder)
          matches = /\A(.*?)\|(.*)\Z/m.match(decoder.buffer)
          raise Errors::ParseError, "invalid format" if matches.nil?
          varName = matches[1]
          decoder.buffer = matches[2]

          decoder.stack.push(varName)
          decoder.state = VarType
        end
      end

      class VarType
        def self.parse(decoder)
          case decoder.buffer
          when /\As:(\d+):(.*)\Z/m # string
            decoder.buffer = $2
            decoder.stack.push($1.to_i)
            decoder.state = String
          when /\Ai:(-?\d+);(.*)\Z/m #int
            decoder.buffer = $2
            decoder.process_value($1.to_i)
          when /\Ad:(-?\d+(?:\.\d+)?);(.*)\Z/m # double
            decoder.buffer = $2
            decoder.process_value($1.to_f)
          when /\Aa:(\d+):(.*)\Z/m # array
            decoder.buffer = $2
            decoder.start_array($1.to_i)
            decoder.state = ArrayStart
          when /\A(N);(.*)\Z/m # null
            decoder.buffer = $2
            decoder.process_value(nil)
          when /\Ab:([01]);(.*)\Z/m # boolean
            decoder.buffer = $2
            bool = case $1
                   when "0" then false
                   when "1" then true
                   end
            decoder.process_value(bool)
          when /\AO:(\d+):(.*)\Z/m # object
            decoder.buffer = $2
            decoder.stack.push($1.to_i);
            decoder.state = ClassName
          when /\A[Rr]:(\d+);(.*)\Z/m # reference count?
            decoder.buffer = $2
            decoder.process_value($1)
          else
            raise Errors::ParseError, "invalid session format"
          end
        end
      end

      class String
        def self.parse(decoder)
          length = decoder.stack.pop
          length_include_quotes = length + 3

          value_include_quotes = decoder.buffer.byteslice(0, length_include_quotes)
          value = value_include_quotes.gsub(/\A"/,'').gsub(/";\Z/, '')

          value = value.encode(decoder.encoding, decoder.encoding_option) if decoder.encoding
          decoder.buffer = decoder.buffer.byteslice(length_include_quotes .. -1)

          decoder.process_value(value)
        end
      end

      class ArrayStart
        def self.parse(decoder)
          raise Errors::ParseError, "invalid array format" unless decoder.buffer =~ /\A{/
            decoder.buffer = decoder.buffer[1..-1]
          if decoder.elements_count > 0
            decoder.state = VarType
          else
            decoder.process_empty_array_value
          end
        end
      end

      class ArrayEnd
        def self.parse(decoder)
          raise Errors::ParseError, "invalid array format" unless decoder.buffer =~ /\A}/
            decoder.buffer = decoder.buffer[1..-1]
          next_state = decoder.in_array ? VarType : VarName;
          decoder.state = next_state
        end
      end

      class ClassName
        def self.parse(decoder)
          length = decoder.stack.pop;
          length_include_quotes = length + 3

          value_include_quotes = decoder.buffer[0, length_include_quotes]
          klass = value_include_quotes.gsub(/\A"/,'').gsub(/":\Z/,'')

          decoder.buffer = decoder.buffer[length_include_quotes..-1]

          raise Errors::ParseError, "invalid class format" unless decoder.buffer =~ /\A(\d+):(.*)/m
          decoder.buffer = $2
          decoder.start_array($1.to_i, klass)
          decoder.state = ArrayStart
        end
      end
    end
  end
end
