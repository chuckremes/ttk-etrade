require_relative "../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_quote_spec"

# RSpec.describe TTK::ETrade::Containers::Quotes::Equity do
#   let(:quote_timestamp) { Time.now }
#   let(:quote_status) { :realtime }
#   let(:ask) { 17.15 }
#   let(:bid) { 17.11 }
#   let(:last) { 17.12 }
#   let(:volume) { 12 }
#
#   subject(:container) do
#     product = make_default_product
#     make_equity_quote(klass: described_class, quote_timestamp: quote_timestamp, quote_status: quote_status,
#                       ask: ask, bid: bid, last: last, volume: volume, product: product)
#   end
#
#   describe "creation" do
#     it "returns a equity quote instance" do
#       expect(container).to be_instance_of(described_class)
#     end
#
#     include_examples "quote interface - required methods equity", TTK::Containers::Quotes::Quote::Equity
#   end
#
#   describe "basic interface" do
#     # quote_timestamp, quote_status, ask, bid, last, and volume must be defined for this to work
#     include_examples "quote interface - equity methods"
#   end
#
#   describe "#update_quote" do
#     let(:security_type) { :equity }
#     let(:update_object) do
#       {
#         quote_timestamp: quote_timestamp,
#         quote_status: quote_status,
#         ask: ask,
#         bid: bid,
#         last: last,
#         volume: volume
#       }
#     end
#
#     include_examples "quote interface - equity update"
#   end
# end
