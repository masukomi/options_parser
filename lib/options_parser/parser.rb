require 'paint'
module OptionsParser
    class Parser

    attr_reader :command, :description, :options, :trailing_values
    # Creates a new instance.
    #
    # Yields itself if called with a block.
    #
    # @param [String] usage usage banner.
    #
    # @yieldparam [ParseOpt] self Option parser object
    def initialize(command:, description: nil)
        @command         = command
        @description     = description
        @options         = []
        @trailing_values = []
        yield self if block_given?
    end

    # Creates an option.
    #
    # @param [String] :short the short flag
    #
    def on(short: nil, long: nil, value_type: nil, help: nil, required: false, &block)
        opt = OptionsParser::Option.new(short: short,
                        long: long,
                        value_type: value_type,
                        help: help,
                        required: required,
                        &block)
        @options.push opt
        opt
    end

    def find_opt_for_arg(arg)
        @options.find{ |opt| opt.matches_arg?(arg) }
    end

    def usage_and_exit()
        usage
        exit 0
    end

    def test_satisfied_or_exit(option)
        raise "No option passed" if option.nil?
        if ! option.satisfied?
            Paint[option.missing_val_text, :red]
            usage_and_exit()
        end
        true
    end

    # Parses all the command line arguments
    def parse(args = ARGV)
        # list. key and value may be in separate elements
        # e.g. ["-f", "from value"]
        # or may be in same element separated by a =
        # e.g. ["--from=from_value"]
        separated_args = args.map{ |x| x.include?("=") ? x.split("=") : x }.flatten



        if separated_args.include?('-h') or separated_args.include?('--help')
        usage_and_exit()
        end

        begin
        current_option = nil
        separator_found = false
        separated_args.each do | arg |
            if separator_found
                @trailing_values.push(arg)
                next
            end
            hyphen_arg = arg.match?(/^-{1,2}\w+$/)
            separator = hyphen_arg ? false : (arg == "--")

            # our first argument flag?
            if current_option.nil? && hyphen_arg
                current_option = find_opt_for_arg(arg)
                raise InvalidOptionException.new("#{arg} is not a supported option") unless current_option
                next
                # an argument flag when we've already encountered one
            elsif current_option && hyphen_arg && test_satisfied_or_exit(current_option)
                # execute the option's block
                current_option = find_opt_for_arg(arg)
                raise InvalidOptionException.new("#{arg} is not a supported option") unless current_option

            elsif current_option && hyphen_arg
                current_option.call()
                next
            # a separator ( no are options after this )
            elsif separator && (current_option.nil? || test_satisfied_or_exit(current_option))
                separator_found = true
                next
            end

            # still here?
            # not an option flag, or separator,
            if !separator_found
                # must be a value that we'll give to the current_option
                current_option&.call(arg)
            else
                @trailing_values.push(arg)
            end
        end
        # end parsing args
        rescue InvalidValueException, InvalidOptionException => e
            puts Paint[e.message, :red]
            usage()
            exit(1)
        end
        # if there's still an option
        # make sure it's satisfied and call its block
        unless current_option.nil?
            test_satisfied_or_exit(current_option)
            current_option.call()
        end

    end

    # Generates the usage output (similar to `--help`)
    def usage()
        top_line_usage =[]
        usage_body = []
        @options.each do |opt|
        usage_text = opt.usage_text
        top_line_usage.push(usage_text)
        usage_body.push(usage_text)
        if opt.help
            usage_body.push("\t" + help.split(/\n/).join("\n\t\t"))
        end
        end
        puts "Usage: #{top_line_usage.join(" ")}"
        puts @description unless @description.nil?
        puts usage_body.join("\n")
    end

  end
end
