# frozen_string_literal: true

RSpec.describe OptionsParser::Parser do

  let(:parser){OptionsParser::Parser.new(command: "testey", description: "cool description")}

  it "has a version number" do
    expect(OptionsParser::VERSION).not_to be nil
  end

  context "#on" do
    it "creates an Option" do
      opt = parser.on(short: "-f")
      expect(opt.class).to(eq(OptionsParser::Option))
    end
    it "adds the new option to Options" do
      opt = parser.on(short: "-f")
      expect(parser.options.size).to(eq(1))
    end
  end

  context "#find_opt_for_arg", :aggregate_failures do
    it "finds by short arg" do
      parser.on(short: "-a", long: "--all")
      parser.on(short: "-b", long: "--ball")
      parser.on(short: "-c", long: "--call")
      found = parser.find_opt_for_arg("-b")
      expect(found.class).to(eq(OptionsParser::Option))
      expect(found.short).to(eq("-b"))
    end
    it "finds by long arg" do
      parser.on(short: "-a", long: "--all")
      parser.on(short: "-b", long: "--ball")
      parser.on(short: "-c", long: "--call")
      found = parser.find_opt_for_arg("--call")
      expect(found.class).to(eq(OptionsParser::Option))
      expect(found.short).to(eq("-c"))
    end
  end

  context ".parse" do
    let(:args){%w[-a 1 --ball -- trail1 trail2 ]}

    it "places anything after -- in trailing values" do
      parser.on(short: "-a", long: "--all", value_type: :integer)
      parser.on(short: "-b", long: "--ball")
      parser.on(short: "-c", long: "--call")
      parser.parse(args)
      expect(parser.trailing_values).to(match_array(%w[trail1 trail2]))
    end

    it "exits if passed invalid option" do
      parser.on(short: "-a", long: "--all", value_type: :integer)
      expect{parser.parse(["-b"])}.to(raise_error(SystemExit))
    end

    it "exits if not passed required option" do
      parser.on(short: "-a", long: "--all", value_type: :integer, required: true)
      parser.on(short: "-b", long: "--ball")
      expect{parser.parse(["-b"])}.to(raise_error(SystemExit))
    end

    it "calls block with value" do
      passed_int = 0
      parser.on(short: "-a", long: "--all", value_type: :integer) do |value|
       passed_int = value
      end
      parser.on(short: "-b", long: "--ball")
      parser.parse(args)
      expect(passed_int).to(eq(1))

    end

    it "handles equals args correctly" do
      args=["-f=v1.0.0"]
      provided_options = {}
      parser.on(short: "-f", long: "--from", value_type: :string, required: true) do |value|
        provided_options[:from] = value
      end
      parser.parse(args)
      expect(provided_options[:from]).to(eq("v1.0.0"))
    end

    it "handles boolean flag before value option" do
      args=["-i", "-f", "v1.0.0"]
      provided_options = {}
      parser.on(short: "-i", long: "--include-all") do |value|
        provided_options[:include_all] = value
      end
      parser.on(short: "-f", long: "--from", value_type: :string) do |value|
        provided_options[:from] = value
      end
      parser.parse(args)
      expect(provided_options[:include_all]).to(eq(true))
      expect(provided_options[:from]).to(eq("v1.0.0"))
    end

    it "handles value option before boolean flag" do
      args=["-f", "v1.0.0", "-i"]
      provided_options = {}
      parser.on(short: "-i", long: "--include-all") do |value|
        provided_options[:include_all] = value
      end
      parser.on(short: "-f", long: "--from", value_type: :string) do |value|
        provided_options[:from] = value
      end
      parser.parse(args)
      expect(provided_options[:from]).to(eq("v1.0.0"))
      expect(provided_options[:include_all]).to(eq(true))
    end

    it "handles boolean flag between value options" do
      args=["-f", "v1.0.0", "-i", "-t", "v1.0.1"]
      provided_options = {}
      parser.on(short: "-i", long: "--include-all") do |value|
        provided_options[:include_all] = value
      end
      parser.on(short: "-f", long: "--from", value_type: :string) do |value|
        provided_options[:from] = value
      end
      parser.on(short: "-t", long: "--to", value_type: :string) do |value|
        provided_options[:to] = value
      end
      parser.parse(args)
      expect(provided_options[:include_all]).to(eq(true))
      expect(provided_options[:from]).to(eq("v1.0.0"))
      expect(provided_options[:to]).to(eq("v1.0.1"))
    end

  end

end
