# frozen_string_literal: true

require_relative '../../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_leg_spec'

RSpec.describe TTK::ETrade::Portfolio::Containers::Response do
  let(:product_body) do
    {
      'securityType' => security_type,
      'symbol' => symbol,
      'callPut' => callput,
      'strikePrice' => strike,
      'expiryYear' => year,
      'expiryMonth' => month,
      'expiryDay' => day
    }
  end

  subject(:container) { described_class.new(body: body) }

  context 'equity' do
    let(:etrade_product) { make_equity_etrade_product }
    let(:product) { make_equity_product(etrade: etrade_product) }
    let(:quote) { make_equity_quote(product: product) }

    let(:execution_time) { Time.now }
    let(:limit_price) { 1.23 }
    let(:leg_id) { '12345' }
    let(:commissions) { 2.34 }
    let(:fees) { 3.45 }
    let(:quantity) { 1 }
    let(:etrade_position_type) { 'LONG' }

    let(:body) do
      {
        'positionId' => leg_id,
        'dateAcquired' => execution_time,
        'pricePaid' => limit_price,
        'commissions' => commissions,
        'otherFees' => fees,
        'quantity' => quantity,
        'positionType' => etrade_position_type,
        'Product' =>
          { 'symbol' => etrade_product.symbol,
            'securityType' => etrade_product.security_type,
            'callPut' => etrade_product.callput,
            'expiryYear' => etrade_product.year,
            'expiryMonth' => etrade_product.month,
            'expiryDay' => etrade_product.day,
            'strikePrice' => etrade_product.strike }
      }
    end

    describe 'creation' do
      it 'returns a portfolio response instance' do
        expect(container).to be_instance_of(described_class)
      end

      include_examples 'leg interface - required methods', TTK::Containers::Leg
    end

    describe 'basic interface' do
      # quote_timestamp, quote_status, ask, bid, last, and volume must be defined for this to work
      # include_examples 'leg interface - methods equity'
    end
  end
end
