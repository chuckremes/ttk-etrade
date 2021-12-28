
require_relative "../../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_leg_spec"
require_relative "../../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_legs_spec"

RSpec.describe TTK::ETrade::Orders::Containers::Response do
  subject(:container) { described_class.new(body: body) }

  let(:body) do
    # all of these variables are overridden by the shared example at various points
    # need defaults set at the top level here though
    make_etrade_orders_response(market_session: market_session, all_or_none: all_or_none,
                                price_type: price_type, limit_price: limit_price,
                                stop_price: stop_price, order_term: order_term)
  end
  let(:market_session) { :regular }
  let(:all_or_none) { true }
  let(:price_type) { :even }
  let(:limit_price) { 0.0 }
  let(:stop_price) { 0.0 }
  let(:order_term) { :day }

  include_examples "legs interface - basic behavior"
end
