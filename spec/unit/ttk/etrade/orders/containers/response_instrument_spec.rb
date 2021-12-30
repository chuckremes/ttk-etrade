require_relative "../../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_leg_spec"

RSpec.describe TTK::ETrade::Orders::Containers::Response::Instrument do
  def convert_status(status)
    status.to_s.upcase
  end

  subject(:container) {
    described_class.new(body: body, placed_time: placed_time,
      execution_time: execution_time, preview_time: preview_time,
      leg_status: convert_status(leg_status))
  }

  let(:body) do
    # all of these variables are overridden by the shared example at various points
    # need defaults set at the top level here though
    make_etrade_instrument(quantity: unfilled_quantity, side: side, direction: direction)
  end
  let(:unfilled_quantity) { 1 }
  let(:filled_quantity) { 0 }
  let(:placed_time) { Time.now.to_i * 1000 }
  let(:execution_time) { Time.now.to_i * 1000 }
  let(:preview_time) { Time.now.to_i * 1000 }
  let(:leg_status) { "OPEN" }
  let(:side) { :long }
  let(:direction) { :opening }

  describe "creation" do
    it "returns a response instrument instance" do
      expect(container).to be_instance_of(described_class)
    end

    include_examples "leg interface with required methods", TTK::Containers::Leg
  end

  include_examples "leg interface basic order behavior"
end
