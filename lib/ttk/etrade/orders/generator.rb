module TTK
  module ETrade
    module Orders
      # Takes some +attributes+ and some quotes and turns them into an ETrade
      # payload of the appropriate shape and contents
      #
      class Generator
        BUY = "BUY"
        SELL = "SELL"
        TO_CLOSE = "CLOSE"
        TO_OPEN = "OPEN"

        def self.cancel(order_id)
          {
            "CancelOrderRequest" => {
              "orderId" => order_id
            }
          }
        end

        def self.preview_vertical(attributes:)
          {
            "PreviewOrderRequest" => {
              "orderType" => to_order_type(attributes.order_type),
              "clientOrderId" => client_order_id,
              "Order" => [
                {
                  "allOrNone" => attributes.all_or_none,
                  "priceType" => to_price_type(attributes.price_type),
                  "limitPrice" => attributes.limit_price.round(2).to_s,
                  "stopPrice" => attributes.stop_price.round(2).to_s,
                  "orderTerm" => to_order_term(attributes.order_term),
                  "marketSession" => to_market_session(attributes.market_session),
                  "Instrument" => to_instrument(attributes.legs)
                }
              ]
            }
          }
        end

        # Takes an +array+ of legs and converts to the Instrument format
        def self.to_instrument(array)
          array.each_with_object([]) do |leg, memo|
            memo << Instrument.from_leg(leg)
          end
        end

        def self.client_order_id
          @@sequence ||= 0
          @@sequence += 1
          # allowed to be a MAX of 20 chars
          # example: "1120-10:16:55.199" (note no 4-digit year)
          Time.now.strftime("%Y%m%d-%H-") + @@sequence.to_s.rjust(7, "0")
        end

        def self.to_order_type(type)
          case type
          when :equity
            "EQ"
          when :equity_option, :single
            "OPTN"
          else
            "SPREADS"
          end
        end

        def self.to_price_type(type)
          case type
          when :credit
            "NET_CREDIT"
          when :debit
            "NET_DEBIT"
          when :even
            "NET_EVEN"
          else
            raise "fill out remainder of price types including #{type}"
          end
        end

        def self.to_market_session(session)
          case session
          when :regular
            "REGULAR"
          when :extended
            "EXTENDED"
          else
            raise "fill out remainder of market sessions including #{session}"
          end
        end

        def self.to_order_term(term)
          case term
          when :day
            "GOOD_FOR_DAY"
          when :gtc
            "GOOD_UNTIL_CANCEL"
          else
            raise "fill out remainder of order terms including #{term}"
          end
        end

        # Uses a previously generated preview payload to construct a place
        # payload
        #
        def self.place_vertical(attributes:, preview:)
          {
            "PlaceOrderRequest" => {
              "orderType" => preview.dig("PreviewOrderRequest", "orderType"),
              "clientOrderId" => preview.dig("PreviewOrderRequest", "clientOrderId"),
              "PreviewIds" => [
                {
                  "previewId" => attributes.preview_id
                }
              ],
              "Order" => preview.dig("PreviewOrderRequest", "Order")
            }
          }
        end

        class Instrument
          BUY_OPEN = "BUY_OPEN"
          BUY_CLOSE = "BUY_CLOSE"
          SELL_OPEN = "SELL_OPEN"
          SELL_CLOSE = "SELL_CLOSE"

          # Converts a +leg+ into the Instrument format
          def self.from_leg(leg)
            {
              "Product" => to_product(leg),
              "orderAction" => to_action(leg),
              "orderedQuantity" => to_quantity(leg),
              "quantity" => to_quantity(leg)
            }
          end

          def self.to_quantity(leg)
            leg.unfilled_quantity.to_s
          end

          def self.to_action(leg)
            case leg.action
            when :buy_to_open
              BUY_OPEN
            when :buy_to_close
              BUY_CLOSE
            when :sell_to_open
              SELL_OPEN
            when :sell_to_close
              SELL_CLOSE
            end
          end

          def self.to_product(leg)
            leg.product.to_product
          end
        end
      end
    end
  end
end
