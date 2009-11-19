module SerializedAttributes
  class AttributeType
    attr_reader :default
    def initialize(default = nil)
      @default = default
    end
    def encode(s) s end
  end

  class Integer < AttributeType
    def parse(input)  input.blank? ? nil : input.to_i end
  end

  class Float < AttributeType
    def parse(input)  input.blank? ? nil : input.to_f end
  end

  class Boolean < AttributeType
    def parse(input)  input && input.respond_to?(:to_i) ? (input.to_i > 0) : input end
    def encode(input) input ? 1 : 0  end
  end

  class String < AttributeType
    # converts unicode (\u003c) to the actual character
    # http://rishida.net/tools/conversion/
    def parse(str)
      return nil if str.nil?
      str = str.to_s
      str.gsub!(/\\u([0-9a-fA-F]{4})/) do |s| 
        int = $1.to_i(16)
        if int.zero? && s != "0000"
          s
        else
          [int].pack("U")
        end
      end
      str
    end
  end

  class Time < AttributeType
    def parse(input)
      return nil if input.blank?
      case input
        when Time   then input
        when String then ::Time.parse(input)
        else input.to_time
      end
    end
    def encode(input) input ? input.utc.xmlschema : nil end
  end

  class << self
    attr_accessor :types
    def add_type(type, object = nil)
      types[type] = object
      Schema.send(:define_method, type) do |*names|
        field type, *names
      end
    end
  end
  self.types = {}
end