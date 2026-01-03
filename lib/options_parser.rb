# frozen_string_literal: true

require_relative "options_parser/version"
require_relative "options_parser/option"
require_relative "options_parser/parser"

module OptionsParser
  class InvalidValueException < StandardError; end
  class InvalidOptionException < StandardError; end
  
end
