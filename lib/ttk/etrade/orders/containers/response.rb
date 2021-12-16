require_relative "generators"

# Used when specifying the contents of a new order. Subclasses
# handle specialty types like equity, equity_option, and spread.
# The various spreads may have specific knowledge on how to
# lay out a multi-legged order.
#
# External interface should be in sync across all containers
# so they can be used interchangeably.
#
class TTK::ETrade::Orders::Containers::Response

  def initialize(body:)
    @body = body

    # OrdersResponse and PlacedOrderResponse are pretty much the same except the
    # order details key has a different name in each. Accommodate both here.
    @order = if body.key?("Order")
               body.dig("Order", 0)
             elsif body.key?("OrderDetail")
               body.dig("OrderDetail", 0)
             else
               STDERR.puts "Check backtrace to see how we got here"
               raise "Never get here"
             end
  end

  # Thinking I may need a ReadOnly module and a Write module where all
  # the methods would be defined for reading Legs + Leg objects or
  # writing them. I think I can be pretty consistent now, so this would
  # majorly DRY things up and simplify testing. Delegation/forwarding
  # would be centralized too, I think. Going to write this class up and
  # then look at refactoring opportunities.

  def legs
    @legs ||= TTK::ETrade::Orders::Containers::Legs.from_instrument(order.dig("Instrument"), order: order)
  end

  def order_type
    case body["orderType"]
    when "SPREADS" then :spread
    when "OPTN" then :option
    when "EQ" then :equity
    else
      :unassigned
    end
  end

  def total_order_value
    body.dig("totalOrderValue")
  end

  def preview_time
    Eastern_TZ.to_local(Time.at((order["previewTime"] || 0) / 1000))
  end

  def placed_time
    Eastern_TZ.to_local(Time.at((order["placedTime"] || 0) / 1000))
  end

  def execution_time
    # ETrade gives us this particular date as milliseconds from epoch
    # Also, all ETrade times are Eastern timezone so convert to our
    # local TZ
    Eastern_TZ.to_local(Time.at((order["executedTime"] || 0) / 1000))
  end

  def dst_flag
    body.dig("dstFlag")
  end

  def account_id
    body.dig("accountId")
  end

  def option_level_cd
    body.dig("optionLevelCd")
  end

  def margin_level_cd
    body.dig("marginLevelCd")
  end

  def status
    order.dig("status").downcase.to_sym
  end

  def order_term
    order.dig("orderTerm")
  end

  def price_type
    case order["priceType"]
    when "NET_DEBIT" then :debit
    when "NET_CREDIT" then :credit
    when "NET_EVEN" then :even
    when "LIMIT" then :limit
    when "MARKET" then :market
    else
      STDERR.puts "add to this waterfall"
      binding.pry
    end
  end

  def limit_price
    order.dig("limitPrice")
  end

  def stop_price
    order.dig("stopPrice")
  end

  def market_session
    order.dig("marketSession").downcase.to_sym
  end

  def all_or_none
    order.dig("allOrNone")
  end

  def messages
    order.dig("messages")
  end

  def estimated_commission
    order.dig("estimatedCommission")
  end

  def estimated_total_amount
    order.dig("estimatedTotalAmount")
  end

  def net_price
    order.dig("netPrice")
  end

  def net_bid
    order.dig("netBid")
  end

  def net_ask
    order.dig("netAsk")
  end

  def preview_id
    raise NotImplementedError
  end

  private

  attr_reader :body, :order
end

class TTK::ETrade::Orders::Containers::Response::Preview < TTK::ETrade::Orders::Containers::Response
  def preview_id
    body.dig("PreviewIds", 0, "previewId")
  end

  def marginable
    OrderBuyPowerEffect.new(body.dig("marginable"))
  end

  def non_marginable
    OrderBuyPowerEffect.new(body.dig("nonMarginable"))
  end

  class OrderBuyPowerEffect
    attr_reader :body

    def initialize(body)
      @body = body
    end

    def current_buying_power
      body.dig("currentBp")
    end

    alias_method :current_bp, :current_buying_power

    def current_open_order_reserve
      body.dig("currentOor")
    end

    alias_method :current_oor, :current_open_order_reserve

    def current_net_buying_power
      body.dig("currentNetBp")
    end

    alias_method :current_net_bp, :current_net_buying_power

    def current_order_impact
      body.dig("currentOrderImpact")
    end

    def net_buying_power
      body.dig("netBp")
    end

    alias_method :net_bp, :net_buying_power
  end
end

class TTK::ETrade::Orders::Containers::Response::Placed < TTK::ETrade::Orders::Containers::Response
  def order_id
    body.dig("OrderIds", 0, "orderId")
  end
end

class TTK::ETrade::Orders::Containers::Response::Existing < TTK::ETrade::Orders::Containers::Response
  def order_id
    body.dig("orderId")
  end

end

class TTK::ETrade::Orders::Containers::Response::Cancel
  attr_reader :body

  def initialize(body:)
    @body = body
  end

  def account_id
    body.dig("accountId")
  end

  def order_id
    body.dig("orderId")
  end

  def cancel_time
    Eastern_TZ.to_local((body["cancelTime"] / 1000.0) || 0)
  end

end
