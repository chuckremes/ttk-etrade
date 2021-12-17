require_relative "../../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_quote_spec"

RSpec.describe TTK::ETrade::Market::Containers::Equity do
  let(:product_body) do
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
  let(:strike) { 0 }
  let(:callput) { nil }
  let(:security_type) { "EQ" }
  let(:year) { 0 }
  let(:month) { 0 }
  let(:day) { 0 }

  let(:quote_timestamp) { Time.now }
  let(:quote_status) { :realtime }
  let(:ask) { 17.15 }
  let(:bid) { 17.11 }
  let(:last) { 17.12 }
  let(:volume) { 12 }

  let(:body) do
    {
      "dateTimeUTC" => quote_timestamp,
      "quoteStatus" => quote_status,
      "Intraday" =>
        { "ask" => ask,
          "bid" => bid,
          "lastTrade" => last,
          "totalVolume" => volume,
        },
      "Product" =>
        { "symbol" => symbol,
          "securityType" => security_type,
          "callPut" => callput,
          "expiryYear" => year,
          "expiryMonth" => month,
          "expiryDay" => day,
          "strikePrice" => strike
        }
    }
  end

  subject(:container) { described_class.new(body: body) }

  describe "creation" do
    it "returns a equity quote instance" do
      expect(container).to be_instance_of(described_class)
    end

    include_examples "quote interface - required methods equity", TTK::Containers::Quotes::Quote::Equity
  end

  describe "basic interface" do
    # quote_timestamp, quote_status, ask, bid, last, and volume must be defined for this to work
    include_examples "quote interface - equity methods"
  end
end

RSpec.describe TTK::ETrade::Market::Containers::EquityOption do
  let(:product_body) do
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

  let(:quote_timestamp) { Time.now }
  let(:quote_status) { :realtime }
  let(:ask) { 17.15 }
  let(:bid) { 17.11 }
  let(:last) { 17.12 }
  let(:volume) { 12 }

  let(:dte) { 14 }
  let(:open_interest) { 4 }
  let(:intrinsic) { 1.23 }
  let(:extrinsic) { 0.45 }
  let(:rho) { 0.0 }
  let(:vega) { 1.2 }
  let(:theta) { -1.4 }
  let(:delta) { 0.5 }
  let(:gamma) { 0.02 }
  let(:iv) { 0.145 }
  let(:multiplier) { 100 }

  let(:body) do
    {
      "dateTimeUTC" => quote_timestamp,
      "quoteStatus" => quote_status,
      "Option" =>
        { "ask" => ask,
          "bid" => bid,
          "lastTrade" => last,
          "totalVolume" => volume,
          "daysToExpiration" => dte,
          "openInterest" => open_interest,
          "intrinsicValue" => intrinsic,
          "timePremium" => extrinsic,
          "optionMultiplier" => multiplier,
          "OptionGreeks" =>
            { "rho" => rho,
              "vega" => vega,
              "theta" => theta,
              "delta" => delta,
              "gamma" => gamma,
              "iv" => iv,
              "currentValue" => false
            }
        },
      "Product" =>
        { "symbol" => symbol,
          "securityType" => security_type,
          "callPut" => callput,
          "expiryYear" => year,
          "expiryMonth" => month,
          "expiryDay" => day,
          "strikePrice" => strike
        }
    }
  end

  subject(:container) { described_class.new(body: body) }

  describe "creation" do
    it "returns a equity_option quote instance" do
      expect(container).to be_instance_of(described_class)
    end

    include_examples "quote interface - required methods equity_option", TTK::Containers::Quotes::Quote::EquityOption
  end

  describe "basic interface" do
    # quote_timestamp, quote_status, ask, bid, last, and volume must be defined for this to work
    include_examples "quote interface - equity_option methods"
  end
end