require_relative "../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_product_spec"

RSpec.describe TTK::ETrade::Containers::Product do
  let(:body) do
    {
      "securityType" => security_type,
      "symbol" => symbol,
      "callPut" => callput,
      "strikePrice" => strike,
      "expiryYear" => year,
      "expiryMonth" => month,
      "expiryDay" => day,
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

  let(:exact_duplicate) { described_class.new(body) }

  let(:different_duplicate) { described_class.new(body.merge("symbol" => "FOO")) }

  describe "creation" do
    it "returns a product instance" do
      expect(container).to be_instance_of(described_class)
    end

    it "allocates an instance of Expiration" do
      expect(described_class::Expiration).to receive(:new).with(body)
      container
    end

    include_examples "product interface - required methods", TTK::Containers::Product
  end

  describe "call option" do
    let(:callput) { "CALL" }

    include_examples "product interface - call"
  end

  describe "put option" do
    let(:callput) { "PUT" }

    include_examples "product interface - put"
  end

  describe "equity" do
    let(:security_type) { "EQ" }

    include_examples "product interface - equity"
  end
end