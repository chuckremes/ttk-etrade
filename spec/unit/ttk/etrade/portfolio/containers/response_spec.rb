# frozen_string_literal: true

require_relative "../../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_leg_spec"

RSpec.describe TTK::ETrade::Portfolio::Containers::Response::Position do
  subject(:container) { described_class.new(body: body) }

  let(:execution_time) { Time.now.to_i }
  let(:price) { 1.23 }
  let(:leg_id) { "12345" }
  let(:commissions) { 2.34 }
  let(:fees) { 3.45 }
  let(:filled_quantity) { 1 }
  let(:unfilled_quantity) { 0 }
  let(:side) { "LONG" }

  let(:body) do
    {
      "positionId" => leg_id,
      "dateAcquired" => execution_time,
      "pricePaid" => price,
      "commissions" => commissions,
      "otherFees" => fees,
      "quantity" => filled_quantity,
      "positionType" => side,
      "Product" =>
        {"symbol" => etrade_product["symbol"],
         "securityType" => etrade_product["securityType"],
         "callPut" => etrade_product["callPut"],
         "expiryYear" => etrade_product["expiryYear"],
         "expiryMonth" => etrade_product["expiryMonth"],
         "expiryDay" => etrade_product["expiryDay"],
         "strikePrice" => etrade_product["strikePrice"]}
    }
  end

  context "equity" do
    let(:etrade_product) { make_etrade_equity_product }
    let(:etrade_quote) { make_etrade_equity_quote(product: etrade_product) }

    describe "creation" do
      it "returns a portfolio response instance" do
        expect(container).to be_instance_of(described_class)
      end

      include_examples "leg interface with required methods", TTK::Containers::Leg
    end
  end

  context "option" do
    let(:etrade_product) { make_etrade_option_product }
    let(:etrade_quote) { make_etrade_option_quote(product: etrade_product) }

    describe "creation" do
      it "returns a portfolio response instance" do
        expect(container).to be_instance_of(described_class)
      end

      include_examples "leg interface with required methods", TTK::Containers::Leg
    end

    context "position leg" do
      let(:price) { 5.21 }
      let(:market_price) { 0.0 }
      let(:stop_price) { 0.0 }
      let(:now) { Time.now }
      let(:placed_time) { TTK::Containers::Leg::EPOCH }
      let(:execution_time) { Time.new(now.year, now.month, now.day, 0, 0, 0, Eastern_TZ).to_i * 1000 }
      let(:preview_time) { TTK::Containers::Leg::EPOCH }
      let(:direction) { :opening }
      let(:quote) { container.quote }

      context "where it is short call then" do
        let(:etrade_product) { make_etrade_option_product(callput: "CALL") }
        let(:side) { "SHORT" }
        let(:filled_quantity) { -2 }

        include_examples "leg interface - short position"
        include_examples "leg interface - short call greeks"
      end

      context "where it is short put then" do
        let(:etrade_product) { make_etrade_option_product(callput: "PUT") }
        let(:side) { "SHORT" }
        let(:filled_quantity) { -2 }

        include_examples "leg interface - short position"
        include_examples "leg interface - short put greeks"
      end

      context "where it is long call then" do
        let(:etrade_product) { make_etrade_option_product(callput: "CALL") }
        let(:side) { "LONG" }
        let(:filled_quantity) { 1 }

        include_examples "leg interface - long position"
        include_examples "leg interface - long call greeks"
      end

      context "where it is long put then" do
        let(:etrade_product) { make_etrade_option_product(callput: "PUT") }
        let(:side) { "LONG" }
        let(:filled_quantity) { 1 }

        include_examples "leg interface - long position"
        include_examples "leg interface - long put greeks"
      end

      include_examples "leg interface basic position behavior"
    end
  end
end
