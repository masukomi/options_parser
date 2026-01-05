# Options Parser

A simple, clean command-line option parser for Ruby.

## Overview

Options Parser provides a straightforward way to define and parse command-line arguments in Ruby applications. It supports short and long flags, typed values, required options, and automatic help generation with colorized output.

It supports

- auto-generated help docs
- required & optional arguments
- short and/or long variations
- arguments that take values, or just act as flags
- separating flag from value with space or equals
- trailing arguments
  Ex. `command -n 4 -- file_1.txt file_2.txt`

## Installation

Add to your Gemfile:

```ruby
gem 'options_parser'
```

Or install directly:

```bash
gem install options_parser
```

**Requires Ruby 3.2+**

## Usage

```ruby
require 'options_parser'

options = {}

parser = OptionsParser::Parser.new(command: "myapp", description: "Does something useful") do |p|
  p.on(short: "-f", long: "--file", value_type: :string, help: "Input file path") do |value|
    options[:file] = value
  end

  p.on(short: "-n", long: "--count", value_type: :integer, help: "Number of iterations") do |value|
    options[:count] = value
  end

  p.on(short: "-r", long: "--rate", value_type: :decimal, help: "Processing rate") do |value|
    options[:rate] = value
  end

  p.on(short: "-v", long: "--verbose", help: "Enable verbose output") do |value|
    options[:verbose] = value  # value is `true` for flags without value_type
  end

  p.on(short: "-o", long: "--output", value_type: :string, required: true, help: "Output file (required)") do |value|
    options[:output] = value
  end
end

parser.parse(ARGV)

# Access trailing arguments (anything after --)
trailing = parser.trailing_values
```
Options have the following attributes:

- `short` - the optional short flag
- `long`  - the optional long flag
- `value_type` - tells the system that the argument takes a value,
  and what kind of value it is. Must be specified if you want to guarantee
  a value is passed.
- `required` - `true` / `false` defaults to false.
- `help` - additional details that will appear in the help docs

Either `short` or `long` _must_ be specified. It doesn't matter which, and specifying both is fine.


### Command Line Examples

```bash
# Short flags
myapp -f input.txt -n 10 -v -o output.txt

# Long flags
myapp --file=input.txt --count=10 --verbose --output=output.txt

# Mixed
myapp -f input.txt --count 10 -v -o output.txt

# With trailing arguments
myapp -f input.txt -o output.txt -- extra1 extra2 extra3
```

## Features

### Value Types

- `:string` - Any string value
- `:integer` - Whole numbers only (validated)
- `:decimal` - Floating point numbers (validated, must include decimal point)

Options without a `value_type` are boolean flags that pass `true` to their block.

### Required Options

Mark an option as required:

```ruby
p.on(short: "-o", long: "--output", value_type: :string, required: true) do |value|
  # ...
end
```

The parser will display an error and usage information if required options are missing.

### Trailing Values

Arguments after `--` are collected in `parser.trailing_values`:

```bash
myapp -f file.txt -- arg1 arg2 arg3
```

```ruby
parser.trailing_values  # => ["arg1", "arg2", "arg3"]
```

### Automatic Help

`-h` and `--help` are automatically handled, displaying usage information and exiting.

### Direct Value Access

Option values can be accessed directly from the option object:

```ruby
file_opt = parser.on(short: "-f", value_type: :string)
parser.parse(ARGV)
file_opt.value  # => the parsed value
```

## Error Handling

Invalid options or values display colorized error messages followed by usage information:

- Missing required options
- Invalid option flags
- Type validation failures (e.g., non-integer passed to `:integer` type)

## License

GPL-2.0-only

## Authors

- masukomi
- Felipe Contreras

Filipe wrote [ruby-parseopt](https://github.com/felipec/ruby-parseopt). masukomi took that as a starting point and modified it until its core functionality was radically different. Now, it's its own thing.
