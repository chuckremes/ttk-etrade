require_relative "../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_product_spec"

RSpec.describe TTK::ETrade::Containers::Product do
  def convert_security_type(t)
    # some shared specs override the #let var, so convert it back here
    case t
    when :equity, "EQ"
      "EQ"
    when :equity_option, "OPTN"
      "OPTN"
    else
      raise "Unknown security type #{t}"
    end
  end

  let(:body) do
    {
      "securityType" => convert_security_type(security_type),
      "symbol" => symbol,
      "callPut" => callput,
      "strikePrice" => strike,
      "expiryYear" => year,
      "expiryMonth" => month,
      "expiryDay" => day
    }
  end

  let(:symbol) { "SPY" }
  let(:strike) { 50 }
  let(:callput) { "CALL" }
  let(:security_type) { "OPTN" }
  let(:year) { 2021 }
  let(:month) { 12 }
  let(:day) { 11 }

  subject(:container) { described_class.new(body) }

  let(:different_container) { described_class.new(body.merge("symbol" => "FOO")) }

  describe "creation" do
    it "returns a product instance" do
      expect(container).to be_instance_of(described_class)
    end

    it "allocates an instance of Expiration" do
      expect(described_class::Expiration).to receive(:new).with(body)
      container
    end

    include_examples "product interface with required methods", TTK::Containers::Product
  end

  describe "call option" do
    let(:callput) { "CALL" }

    include_examples "product interface with basic call option behaviors"
  end

  describe "put option" do
    let(:callput) { "PUT" }

    include_examples "product interface with basic put option behaviors"
  end

  describe "equity" do
    let(:security_type) { "EQ" }

    include_examples "product interface with basic equity instrument behaviors"
  end
end
