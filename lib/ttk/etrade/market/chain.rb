module TTK
  module ETrade
    module Market
      class Chain
        include Enumerable

        def initialize
          @collection = []
        end

        def update(from_hash:)
          @body = from_hash
          # Calling #clear will remove these references but any Quotes that were registered
          # for subscription will remain. So this will be a memory leak if we reload
          # option chains on a regular basis.
          @collection.clear
          self
        end

        def each(&blk)
          if @collection.empty?
            year, month, day = [body.dig("SelectedED", "year"), body.dig("SelectedED", "month"), body.dig("SelectedED", "day")]
            quote_type = body.dig("quoteType")
            near_price = body.dig("nearPrice")
            pp [year, month, day]

            (body.dig("OptionPair") || []).map do |pair|
              pair.values.each do |option|
                @collection << TTK::ETrade::Market::Containers::Response.new(
                  body: reformat(option, year, month, day, quote_type, near_price))
              end
            end
          end

          @collection.each do |option|
            yield(option)
          end
        end

        private

        # Turns an OptionPair option into the same form as a QuoteData hash
        def reformat(option, year, month, day, quote_type, near_price)
          midpoint = ((option["ask"].to_f + option["bid"].to_f) / 2.0).round(2, half: :down)

          # hacks... best to request a real quote but
          # these values will do in a pinch
          intrinsic = if option["inTheMoney"] == "y"
                        (near_price - option["strikePrice"]).abs
                      else
                        intrinsic = 0.0
                      end

          extrinsic = if intrinsic > 0
                        midpoint - intrinsic
                      else
                        midpoint
                      end

          {
            "dateTimeUTC" => option["timeStamp"],
            "quoteStatus" => quote_type,
            "ahFlag" => "false",
            "Option" =>
              {"ask" => option["ask"],
                "askSize" => option["askSize"],
                "bid" => option["bid"],
                "bidSize" => option["bidSize"],
                "daysToExpiration" => (Date.new(year, month, day) - Date.today).to_i,
                "lastTrade" => option["lastPrice"],
                "openInterest" => option["openInterest"],
                "intrinsicValue" => intrinsic,
                "timePremium" => extrinsic,
                "symbolDescription" => option["displaySymbol"],
                "OptionGreeks" =>
                  {"rho" => option.dig("OptionGreeks", "rho"),
                    "vega" => option.dig("OptionGreeks", "vega"),
                    "theta" => option.dig("OptionGreeks", "theta"),
                    "delta" => option.dig("OptionGreeks", "delta"),
                    "gamma" => option.dig("OptionGreeks", "gamma"),
                    "iv" => option.dig("OptionGreeks", "iv"),
                    "currentValue" => false}},
            "Product" =>
              {"symbol" => option["optionRootSymbol"],
                "securityType" => "OPTN",
                "callPut" => option["optionType"],
                "expiryYear" => year,
                "expiryMonth" => month,
                "expiryDay" => day,
                "strikePrice" => option["strikePrice"]}}
        end

        attr_reader :body
      end
    end
  end
end
