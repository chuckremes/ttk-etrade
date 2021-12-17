require_relative "../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_quote_spec"

# RSpec.describe TTK::ETrade::Containers::Quotes::EquityOption do
#   let(:quote_timestamp) { Time.now }
#   let(:quote_status) { :realtime }
#   let(:ask) { 17.15 }
#   let(:bid) { 17.11 }
#   let(:last) { 17.12 }
#   let(:volume) { 12 }
#   let(:dte) { 0 }
#   let(:open_interest) { 14 }
#   let(:intrinsic) { 0.0 }
#   let(:extrinsic) { 0.0 }
#   let(:multiplier) { 100 }
#   let(:delta) { 0.0 }
#   let(:theta) { 0.0 }
#   let(:gamma) { 0.0 }
#   let(:vega) { 0.0 }
#   let(:rho) { 0.0 }
#   let(:iv) { 0.0 }
#
#   subject(:container) do
#     described_class.new(quote_timestamp: quote_timestamp,
#                         quote_status: quote_status,
#                         ask: ask,
#                         bid: bid,
#                         last: last,
#                         volume: volume,
#                         dte: dte,
#                         open_interest: open_interest,
#                         intrinsic: intrinsic,
#                         extrinsic: extrinsic,
#                         multiplier: multiplier,
#                         delta: delta,
#                         theta: theta,
#                         gamma: gamma,
#                         vega: vega,
#                         rho: rho,
#                         iv: iv
#     )
#   end
#
#   describe "creation" do
#     it "returns a equity_quote instance" do
#       expect(container).to be_instance_of(described_class)
#     end
#
#     include_examples "quote interface - required methods equity_option", TTK::Containers::Quotes::Quote::EquityOption
#   end
#
#   describe "basic interface" do
#     # quote_timestamp, quote_status, ask, bid, last, and volume must be defined for this to work
#     # also requires delta, gamma, theta, vega, rho, iv, dte, open_interest, multiplier, intrinsic, and extrinsic
#     include_examples "quote interface - equity_option methods"
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
#         volume: volume,
#         dte: dte,
#         open_interest: open_interest,
#         intrinsic: intrinsic,
#         extrinsic: extrinsic,
#         delta: delta,
#         theta: theta,
#         gamma: gamma,
#         vega: vega,
#         rho: rho,
#         iv: iv
#       }
#     end
#
#     include_examples "quote interface - equity_option update"
#   end
# end
