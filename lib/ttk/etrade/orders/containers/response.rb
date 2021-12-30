# require_relative "generators"
require_relative "../../../../../../ttk-containers/lib/ttk/containers/legs/shared"
require_relative "../../../../../../ttk-containers/lib/ttk/containers/leg/shared"

# Used when specifying the contents of a new order. Subclasses
# handle specialty types like equity, equity_option, and spread.
# The various spreads may have specific knowledge on how to
# lay out a multi-legged order.
#
# External interface should be in sync across all containers
# so they can be used interchangeably.
#
module TTK
  module ETrade
    module Orders
      module Containers
        class Response
          include TTK::Containers::Legs::Order::ComposedMethods

          def initialize(body:)
            @body = body

            # OrdersResponse and PlacedOrderResponse are pretty much the same except the
            # order details key has a different name in each. Accommodate both here.
            @order = if body.key?("Order")
                       body.dig("Order", 0)
                     elsif body.key?("OrderDetail")
                       body.dig("OrderDetail", 0)
                     else
                       warn "Check backtrace to see how we got here"
                       raise "Never get here"
                     end
          end

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
            case order.dig("orderTerm")
            when "GOOD_FOR_DAY" then :day
            when "GOOD_UNTIL_CANCEL" then :gtc
            else raise "never get here, add to case waterfall"
            end
          end

          def price_type
            case order["priceType"]
            when "NET_DEBIT" then :debit
            when "NET_CREDIT" then :credit
            when "NET_EVEN" then :even
            when "LIMIT" then :limit
            when "MARKET" then :market
            else
              warn "add to this waterfall"
              binding.pry
            end
          end

          def limit_price
            order.dig("limitPrice")
          end
          alias_method(:price, :limit_price)

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

          def commission
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

        # Reopen class Response
        class Response
          class Preview < Response
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

          class Placed < Response
            def order_id
              body.dig("OrderIds", 0, "orderId")
            end
          end

          class Existing < Response
            def order_id
              body.dig("orderId")
            end
          end

          class Cancel
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

          # This is the "Leg" class for Order Responses and conforms to the
          # Leg interface
          class Instrument
            include TTK::Containers::Quote::Forward
            include TTK::Containers::Product::Forward
            include TTK::Containers::Leg::ComposedMethods

            attr_reader :body, :product, :quote

            def initialize(body:, placed_time:, execution_time:, preview_time:, leg_status:)
              @body = body
              @product = TTK::ETrade::Containers::Product.new(body["Product"])
              @quote = TTK::ETrade::Market::Containers::Response.null_quote(product: body["Product"])
              @placed_time = placed_time || TTK::Containers::Leg::EPOCH
              @execution_time = execution_time || TTK::Containers::Leg::EPOCH
              @preview_time = @preview_time || TTK::Containers::Leg::EPOCH
              @leg_status = leg_status
            end

            def side
              case body["orderAction"]
              when "SELL_OPEN", "SELL_CLOSE", "SELL"
                :short
              when "BUY_OPEN", "BUY_CLOSE", "BUY"
                :long
              end
            end

            def unfilled_quantity
              body["orderedQuantity"].to_i
            end

            def filled_quantity
              0
            end

            def price
              body["averageExecutionPrice"].to_f
            end

            def market_price
              0.0
            end

            def stop_price
              body["stopPrice"].to_f
            end

            def placed_time
              Eastern_TZ.to_local(Time.at(@placed_time || 0))
            end

            def execution_time
              Eastern_TZ.to_local(Time.at(@execution_time || 0))
            end

            def preview_time
              Eastern_TZ.to_local(Time.at(@preview_time || 0))
            end

            def leg_status
              # OPEN, EXECUTED, CANCELLED, INDIVIDUAL_FILLS,
              # CANCEL_REQUESTED, EXPIRED, REJECTED, PARTIAL, DO_NOT_EXERCISE, DONE_TRADE_EXECUTED
              case @leg_status
              when "OPEN", "EXECUTED", "CANCELLED", "CANCEL_REQUESTED", "EXPIRED", "REJECTED"
                @leg_status.downcase.to_sym
              when "INDIVIDUAL_FILLS", "PARTIAL"
                :partially_executed
              when "DO_NOT_EXERCISE", "DONE_TRADE_EXECUTED"
                :unknown
              else
                :unknown
              end
            end

            def leg_id

            end

            def fees
              body["estimatedFees"].to_f
            end

            def commission
              body["estimatedCommission"].to_f
            end

            def direction
              case body["orderAction"]
              when "SELL_OPEN", "BUY", "BUY_OPEN"
                :opening
              when "BUY_CLOSE", "SELL_CLOSE", "SELL"
                :closing
              end
            end
          end
        end
      end
    end
  end
end
