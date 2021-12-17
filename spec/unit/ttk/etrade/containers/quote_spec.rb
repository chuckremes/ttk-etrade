require_relative "../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_quote_spec"


RSpec.describe TTK::ETrade::Containers::Quotes::Equity do
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

  let(:module_extension) do
    Module.new do
      def set(key, value)
        new_body = body.dup
        case key
        when :quote_timestamp then new_body["dateTimeUTC"] = value
        when :quote_status then new_body["quoteStatus"] = value
        when :ask then new_body["Intraday"]["ask"] = value
        when :bid then new_body["Intraday"]["bid"] = value
        when :last then new_body["Intraday"]["lastTrade"] = value
        when :volume then new_body["Intraday"]["totalVolume"] = value
        end

        # return new object
        TTK::ETrade::Market::Containers::Equity.new(body: new_body)
      end
    end
  end

  let(:response_instance) { TTK::ETrade::Market::Containers::Equity.new(body: body) }

  subject(:container) { described_class.new(body: response_instance) }

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

  describe "#update_quote" do
    before do
      # add a feature to allow for updates during test
      response_instance.extend(module_extension)
    end

    let(:update_object) do
      response_instance
    end

    include_examples "quote interface - equity update"
  end
end
