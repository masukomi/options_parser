require 'paint'

module OptionsParser
  class Option
    attr_reader :short, :long, :help, :required, :value

    VALUE_TYPES = [:string, :decimal, :integer]

    def initialize(short: nil, long: nil, value_type: nil, help: nil, required: false, &block)
      @value_type = value_type;
      @block = block
      @short = short
      @long = long
      @help = help
      @required = false if required.nil?
      @value = nil
      raise "Option must contain a short or long flag" if @short.nil? && @long.nil?
    end

    def matches_arg?(arg)
      return [@short, @long].include?(arg)
    end

    def takes_value?
      return ! @value_type.nil?
    end

    # @returns true if it doesn't take a value, or if its value has been found
    def satisfied?
      return ! @value.nil?
    end

    def missing_val_text()
      usage_elements = []
      usage_elements.push(short) if @short
      usage_elements.push(" / ") if @short && @long
      usage_elements.push(long) if @long
      usage_elements.push("takes a #{@value_type}")
      return usage_elements.join(" ")
    end

    def usage_text()
      usage_elements = []
      usage_elements.push("[") unless @required
      usage_elements.push(short) if @short
      usage_elements.push(", ") if @short && @long
      usage_elements.push(long) if @long
      if takes_value?
        usage_elements.push("=#{@value_type.upcase}")
      end
      usage_elements.push("]") unless @required
      usage_elements.join(" ")
    end

    def get_minimal_args
      args = []
      args.push(@short) unless @short.nil?
      args.push("/") if !@short.nil? && !@long.nil?
      args.push(@long) unless @long.nil?
      args.join("")
    end
    def convert_value(value, type)
      return value      if type == :string
      if type == :integer
        raise InvalidValueException.new("#{get_minimal_args} value must be an integer") \
          unless value.match?(/^\d+$/)
        return value.to_i
      end
      if type == :decimal
        raise InvalidValueException.new("#{get_minimal_args} value must be a decimal") \
          unless value.match?(/^\d+\.\d+$/)
        return value.to_f
      end
      raise "unsupported value type: #{type}"
    end

    # passes the converted value to the block.
    # If no value is supplied by the user the block
    # will be passed true
    def call(value = nil)
      if takes_value? && ! value.nil?
        value = convert_value(value, @value_type)
      elsif takes_value?
        raise InvalidValueException.new("I was passed a nil value. Shouldn't happen.")
      else
        value = true
      end
      # setting value in case they want to reference it directly
      # and to make satisfied? return true
      @value = value
      @block&.call(value)
    end
  end
end
