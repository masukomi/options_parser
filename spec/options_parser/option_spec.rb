# frozen_string_literal: true

RSpec.describe OptionsParser::Option do
  it "saves the value as true when called if it doesn't take a value" do
    opt = OptionsParser::Option.new(short: "-f") do
      "nothing"
    end
    expect(opt.value).to(eq(nil))
    opt.call(false)
    expect(opt.value).to(eq(true))
    opt.call()
    expect(opt.value).to(eq(true))
  end

  it "raises as error if initialized without short or long" do
    expect{OptionParser::Option.new(help: "bah")}.to(raise_error(StandardError))
  end

  context "#takes_value?" do
    it "takes a value if value_type is set" do
      opt = OptionsParser::Option.new(short: "-f", value_type: :string) do
        "nothing"
      end
      expect(opt.takes_value?).to(eq(true))
    end
    it "doesn't take a value if value_type is not set" do
      opt = OptionsParser::Option.new(short: "-f") do
        "nothing"
      end
      expect(opt.takes_value?).to(eq(false))
    end
  end
  context "#satisfied?" do
    context "when doesn't take value" do
      it "returns false if call hasn't been called" do
        opt = OptionsParser::Option.new(short: "-f") do
          "nothing"
        end
        expect(opt.satisfied?).to(eq(false))
      end
      it "returns true when call has been called" do
        opt = OptionsParser::Option.new(short: "-f") do
          "nothing"
        end
        opt.call()
        expect(opt.satisfied?).to(eq(true))
      end
    end
    context "when it does take a value" do
      it "returns false if call hasn't been called" do
        opt = OptionsParser::Option.new(short: "-f", value_type: :string) do
          "nothing"
        end
        expect(opt.satisfied?).to(eq(false))
      end
      it "returns true when call has been called" do
        opt = OptionsParser::Option.new(short: "-f", value_type: :string) do
          "nothing"
        end
        opt.call("foo")
        expect(opt.satisfied?).to(eq(true))
      end
    end
  end


  context "when it takes a string" do
    it "saves the string value passed" do
      opt = OptionsParser::Option.new(short: "-f", value_type: :string) do
        "nothing"
      end
      expect(opt.value).to(eq(nil))
      opt.call("foo")
      expect(opt.value).to(eq("foo"))

    end
    it "raises an exception if passed nil" do
      opt = OptionsParser::Option.new(short: "-f", value_type: :string) do
        "nothing"
      end
      expect{ opt.call()}.to(raise_error(OptionsParser::InvalidValueException))
    end
  end
end
