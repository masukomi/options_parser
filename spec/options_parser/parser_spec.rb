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
  end

end
