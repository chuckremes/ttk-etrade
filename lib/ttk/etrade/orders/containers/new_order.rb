require_relative "generators"
require "forwardable"
require_relative "../../../../../../ttk-containers/lib/ttk/containers/legs/shared"

# Used when specifying the contents of a new order. Subclasses
# handle specialty types like equity, equity_option, and spread.
# The various spreads may have specific knowledge on how to
# lay out a multi-legged order.
#
# External interface should be in sync across all containers
# so they can be used interchangeably.
#
# This file essentially implements the logic to manipulate an
# ETrade PreviewOrderRequest to create an order. Change an
# order here too or do elsewhere?
#
class TTK::ETrade::Orders::Containers::NewOneLeg
  include TTK::Containers::Legs::Order::ComposedMethods
  # include TTK::ETrade::Orders::Containers::ContainerShared
  # include TTK::ETrade::Orders::Containers::ContainerGreeks

  extend Forwardable
  def_delegators :@legs,
                 :action=,
                 :quantity=
  def_delegators :@payload,
                 :order_type=,
                 :client_order_id=,
                 :all_or_none=,
                 :price_type=,
                 :limit_price=,
                 :limit_price,
                 :stop_price=,
                 :stop_price,
                 :order_term=,
                 :market_session=

  def initialize(interface:)
    @interface = interface
    @payload = TTK::ETrade::Orders::Containers::Generators::Payload.new
    legs
    @payload.legs = @legs
  end

  def legs
    @legs ||= TTK::ETrade::Orders::Containers::Generators::OneLeg.new
  end

  def set_legs(leg)
    raise NotImplementedError
    self
  end

  # Calls the Interface to submit a preview order
  #
  def submit_preview
    structure = <<-JSON
    {
      "PreviewOrderRequest": {
        "orderType": "SPREADS",
        "clientOrderId": "34s53f3",
        "Order": [
                       {
                         "allOrNone": "false",
                         "priceType": "NET_CREDIT",
                         "limitPrice": "5",
                         "stopPrice": "0",
                         "orderTerm": "GOOD_FOR_DAY",
                         "marketSession": "REGULAR",
                         "Instrument": [{
                                          "Product":
                                            { "symbol": "FB", "securityType": "OPTN", "callPut": "CALL", "expiryYear": "2021", "expiryMonth": "12", "expiryDay": "17", "strikePrice": "360" } ,
                                        "orderAction": "SELL_OPEN",
                                        "orderedQuantity": "1",
                                        "quantity": "1"
                       },
{
                                          "Product":
                                            { "symbol": "FB", "securityType": "OPTN", "callPut": "CALL", "expiryYear": "2021", "expiryMonth": "12", "expiryDay": "17", "strikePrice": "370" } ,
                                        "orderAction": "BUY_OPEN",
                                        "orderedQuantity": "1",
                                        "quantity": "1"
                       }]}]}
}
    JSON
    structure = to_preview
    # pp structure
    @preview = interface.submit_preview(structure)
  rescue TTK::ETrade::Errors::OrderWarning => e
    # some warnings are more important than others, but for the most
    # part we just want to record it happened otherwise it"s not an error

  rescue TTK::ETrade::Errors::OrderError => e
    # any errors thrown by the API should get wrapped and captured here
    # Use Null Object pattern with a Null Error to handle the common case
    @preview_error = e
  end

  # Parses the result of an earlier call to #submit_preview and returns
  # true or false depending on the warnings and errors returned.
  #
  def preview_ok?
    true #!!(@preview_error&.failure?)
  end

  def submit
    structure = <<-JSON
{
"PlaceOrderRequest": {
"orderType": "SPREADS",
"clientOrderId": "34s53f3",
"PreviewIds":[
{ "previewId": #{@preview.preview_id} }
],
"Order": [
{
"allOrNone": "false",
"priceType": "NET_CREDIT",
"limitPrice": "5",
"stopPrice": "0",
"orderTerm": "GOOD_FOR_DAY",
"marketSession": "REGULAR",
"Instrument": [{
"Product":
{ "symbol": "FB", "securityType": "OPTN", "callPut": "CALL", "expiryYear": "2021", "expiryMonth": "12", "expiryDay": "17", "strikePrice": "360" },
"orderAction": "SELL_OPEN",
"orderedQuantity": "1",
"quantity": "1"
},
{
                                          "Product":
                                            { "symbol": "FB", "securityType": "OPTN", "callPut": "CALL", "expiryYear": "2021", "expiryMonth": "12", "expiryDay": "17", "strikePrice": "370" } ,
                                        "orderAction": "BUY_OPEN",
                                        "orderedQuantity": "1",
                                        "quantity": "1"
                       }
]}]}}
    JSON
    structure = to_place(@preview)

    pp "place structure", structure
    @placed = interface.submit_order(structure)
    @placed.order_id
    # pp "placed response", @placed
    TTK::ETrade::Orders::Containers::Existing.new(body: @placed,
                                                  interface: interface,
                                                  account_key: @account_key)

  end

  def submit_ok?
    true
  end

  def order_id
    @placed&.order_id
  end

  # Can be called by an Existing order to get the preview structure to change that order
  def to_preview
    @payload.to_preview
  end

  def to_place(preview)
    @payload.to_place(preview)
  end

  private

  attr_reader :interface
end

class TTK::ETrade::Orders::Containers::NewTwoLeg < TTK::ETrade::Orders::Containers::NewOneLeg

  def legs
    @legs ||= TTK::ETrade::Orders::Containers::Generators::TwoLegs.new
  end

  def set_legs(body_leg: nil, wing_leg: nil, legs: nil)
    if body_leg && wing_leg
      @legs.body_leg = body_leg
      @legs.wing_leg = wing_leg
    elsif legs
      # logic to set the legs in correct order
      if legs.all?(&:put?)
        @legs.body_leg = legs.sort_by(&:strike).to_a[1]
        @legs.wing_leg = legs.sort_by(&:strike).to_a[0]
      elsif legs.all?(&:call?)
        @legs.body_leg = legs.sort_by(&:strike).to_a[0]
        @legs.wing_leg = legs.sort_by(&:strike).to_a[1]
      else
        raise "Another bug, no mixing allowed yet"
      end
    else
      raise "Uh oh, bug"
    end

    self
  end

  # Set mimimum values necessary for this container type to pass the Core::Combo
  # sanity checks
  def set_defaults
    self.quantity = 1
    self.action = :buy_to_open
    self.order_type = :spread
    self.price_type = :even
    self.limit_price = 0.0
  end
end


