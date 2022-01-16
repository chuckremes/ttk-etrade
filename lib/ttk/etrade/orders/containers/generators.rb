require "forwardable"
require_relative "shared"
require_relative "../../../../../../ttk-containers/lib/ttk/containers/legs/shared"
require_relative "../../../../../../ttk-containers/lib/ttk/containers/leg/shared"

# These classes all work together. The Container classes use
# these helpers to collect the information on an order and then
# these classes can easily generate the correct payload structure
# for the API calls to ETrade.
#
module TTK::ETrade::Orders::Containers::Generators
  # Let"s us set all sorts of variables on this structure. Then we can
  # call #to_preview, #to_preview_change, or #to_place and it will
  # auto-generate the correct hash body.
  #
  class Payload
    attr_reader :legs, :order_type

    def order_value
      0 # midpoint * multiplier would probably work :)
    end

    def place_time
      Eastern_TZ.to_local(Time.at(0))
    end

    def execution_time
      Eastern_TZ.to_local(Time.at(0))
    end

    def status
      :new
    end

    def legs=(value)
      @legs = value
    end

    def order_type=(value)
      raise "Bad value [#{value}]" unless [:equity, :equity_option, :spread].include?(value)
      @order_type = case value
                    when :equity then "EQ"
                    when :equity_option then "OPTN"
                    when :spread then "SPREADS"
                    end
    end

    def client_order_id=(value)
      @client_order_id = value
    end

    def client_order_id
      # allowed to be a MAX of 20 chars
      # example: "1120-10:16:55.199" (note no 4-digit year)
      @client_order_id ||= Time.now.strftime("%m%d-%H:%M:%S.%L")
    end

    def all_or_none=(value)
      raise "Bad value [#{value}]" unless [true, false].include?(value)
      @all_or_none = value.to_s
    end

    def all_or_none
      @all_or_none ||= "false"
    end

    def price_type=(value)
      raise "Bad value [#{value}]" unless [:debit, :credit, :market, :limit, :stop,
                                           :stop_limit, :even, :market_on_open,
                                           :market_on_close, :limit_on_open, :limit_on_close].include?(value)
      @price_type = case value
                    when :credit then "NET_CREDIT"
                    when :debit then "NET_DEBIT"
                    when :market then "MARKET"
                    when :limit then "LIMIT"
                    when :stop then "STOP"
                    when :stop_limit then "STOP_LIMIT"
                    when :even then "NET_EVEN"
                    when :market_on_open then "MARKET_ON_OPEN"
                    when :market_on_close then "MARKET_ON_CLOSE"
                    when :limit_on_open then "LIMIT_ON_OPEN"
                    when :limit_on_close then "LIMIT_ON_CLOSE"
                    end
    end

    def price_type
      @price_type
    end

    def limit_price=(value)
      raise "Bad value [#{value}]" unless value.kind_of?(Numeric)
      @limit_price = value
    end

    def limit_price
      @limit_price
    end

    def stop_price=(value)
      raise "Bad value [#{value}]" unless value.kind_of?(Numeric)
      @stop_price = value
    end

    def stop_price
      # nil is okay so convert to 0
      @stop_price || 0
    end

    def order_term=(value)
      raise "Bad value [#{value}]" unless [:day, :gtc].include?(value)
      @order_term = case value
                    when :day then "GOOD_FOR_DAY"
                    when :gtc then "GOOD_UNTIL_CANCEL"
                    when :gtd then "GOOD_TILL_DATE"
                    when :immediate then "IMMEDIATE_OR_CANCEL"
                    when :fok then "FILL_OR_KILL"
                    end
    end

    def order_term
      @order_term || "GOOD_FOR_DAY"
    end

    def market_session=(value)
      raise "Bad value [#{value}]" unless [:regular, :extended].include?(value)
      @order_term = case value
                    when :regular then "REGULAR"
                    when :extended then "EXTENDED"
                    end
    end

    def market_session
      @market_session || "REGULAR"
    end

    def to_preview
      {
        "PreviewOrderRequest" => {
          "orderType"     => order_type,
          "clientOrderId" => client_order_id,
          "Order"         => [
            {
              "allOrNone"     => all_or_none,
              "priceType"     => price_type,
              "limitPrice"    => limit_price.round(2).to_s,
              "stopPrice"     => stop_price.round(2).to_s,
              "orderTerm"     => order_term,
              "marketSession" => market_session,
              "Instrument"    => legs.to_instrument
            }
          ]
        }
      }
    end

    def to_place(preview)
      {
        "PlaceOrderRequest" => {
          "orderType"     => order_type,
          "clientOrderId" => client_order_id,
          "PreviewIds" => [
            {
              "previewId" => preview.preview_id
            }
          ],
          "Order"         => [
            {
              "allOrNone"     => all_or_none,
              "priceType"     => price_type,
              "limitPrice"    => limit_price.round(2).to_s,
              "stopPrice"     => stop_price.round(2).to_s,
              "orderTerm"     => order_term,
              "marketSession" => market_session,
              "Instrument"    => legs.to_instrument
            }
          ]
        }
      }
    end

    def to_cancel(order_id)
      {
        "CancelOrderRequest" => {
          "orderId" => order_id
        }
      }
    end
  end

  class TTK::ETrade::Orders::Containers::Generators::OneLeg
    include Enumerable

    def each(&blk)
      yield(leg)
    end

    def leg=(value)
      # kind_of? and is_a? doesn"t work right with delegates
      # raise "Bad value #{value}" unless value.kind_of?(TTK::ETrade::Orders::Containers::LegShared) # Quote, yada yada
      raise "Bad value #{value}" unless value.kind_of?(BasicObject) # Quote, yada yada
      @leg = value
    rescue => e
      binding.pry
    end

    def leg
      Leg.new(quote: @leg, quantity: quantity, action: action)
    end

    def quantity=(value)
      raise "Bad value [#{value}]" unless value.kind_of?(Numeric)
      @quantity = value.to_i
    end

    def quantity
      @quantity
    end

    def action=(value)
      raise "Bad value [#{value}]" unless [:sell_to_open, :sell_to_close, :buy_to_open, :buy_to_close,
                                           :buy, :sell].include?(value)
      @action = value
    end

    def action
      @action
    end

    def to_instrument
      [
        leg.to_instrument,
      ]
    end

  end

  class TTK::ETrade::Orders::Containers::Generators::TwoLegs < TTK::ETrade::Orders::Containers::Generators::OneLeg
    alias_method(:body_leg=, :leg=)
    alias_method(:body_leg, :leg)

    def each(&blk)
      [body_leg, wing_leg].each { |l| yield(l) }
    end

    def wing_leg=(value)
      raise "Bad value #{value}" unless value.kind_of?(BasicObject) # Quote, yada yada
      @wing_leg = value
    end

    def wing_leg
      Leg.new(quote: @wing_leg, quantity: quantity, action: paired(action))
    end

    def paired(action)
      case action
      when :sell then :buy
      when :buy then :sell
      when :sell_to_open then :buy_to_open
      when :sell_to_close then :buy_to_close
      when :buy_to_open then :sell_to_open
      when :buy_to_close then :sell_to_close
      end
    end

    def to_instrument
      [
        body_leg.to_instrument,
        wing_leg.to_instrument
      ]
    end
  end

  class TTK::ETrade::Orders::Containers::Generators::Leg
    include TTK::Containers::Quote::Forward
    include TTK::Containers::Product::Forward
    include TTK::Containers::Leg::ComposedMethods
    # include TTK::ETrade::Orders::Containers::LegShared
    # extend Forwardable
    # def_delegators :@quote,
    #                :product,
    #                :symbol,
    #                :expiration_date,
    #                :expiration_string,
    #                :strike,
    #                :callput,
    #                :call?,
    #                :put?,
    #                :equity?,
    #                :equity_option?,
    #                :osi,
    #                :iv,
    #                :bid,
    #                :ask,
    #                :midpoint,
    #                :gamma,
    #                :theta,
    #                :rho
    # include TTK::ETrade::Core::Quotes::Subscriber
    # include TTK::ETrade::Orders::Containers::LegGreeks

    def initialize(quote:, quantity:, action:)
      self.quantity = quantity
      self.action   = action
      self.quote    = quote
    end

    def to_instrument
      {
        "Product"         => quote.to_product,
        "orderAction"     => action,
        "orderedQuantity" => quantity.to_s,
        "quantity"        => quantity.to_s
      }
    end

    def unfilled_quantity
      quantity
    end

    def filled_quantity
      0
    end

    def commission
      0
    end

    def fees
      0
    end

    def quantity=(value)
      raise "Bad value [#{value}]" unless value.kind_of?(Numeric)
      @quantity = value.to_i
    end

    def quantity
      @quantity
    end

    def action=(value)
      raise "Bad value [#{value}]" unless [:sell_to_open, :sell_to_close, :buy_to_open, :buy_to_close,
                                           :buy, :sell].include?(value)
      @action = case value
                when :sell_to_open then "SELL_OPEN"
                when :sell_to_close then "SELL_CLOSE"
                when :buy_to_open then "BUY_OPEN"
                when :buy_to_close then "BUY_CLOSE"
                when :buy then "BUY"
                when :sell then "SELL"
                end
    end

    def action
      @action
    end

    def side
      if action =~ /sell/i
        :short
      elsif action =~ /buy/i
        :long
      else
        binding.pry
        raise "should never get here"
      end
    end

    def quote=(value)
      raise "Bad value #{value}" unless value.kind_of?(BasicObject) # Quote, yada yada
      @quote = value
    end

    def quote
      @quote
    end
  end

end
