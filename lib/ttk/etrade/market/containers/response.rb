# for ComposedMethods
# temporary until ttk-containers is made into a real gem
require_relative "../../../../../../ttk-containers/lib/ttk/containers/quote/shared"

module TTK
  module ETrade
    module Market
      module Containers
        # Example of an Option quote from ETrade QuoteData payload:
        #
        #       {
        #         "dateTimeUTC" => 0,
        #         "quoteStatus" => "DELAYED",
        #         "ahFlag" => "false",
        #         "Option" =>
        #           { "ask" => 0,
        #             "askSize" => 0,
        #             "bid" => 0,
        #             "bidSize" => 0,
        #             "daysToExpiration" => 0,
        #             "lastTrade" => 0,
        #             "openInterest" => 0,
        #             "intrinsicValue" => 0,
        #             "timePremium" => 0,
        #             "symbolDescription" => "Null quote",
        #             "OptionGreeks" =>
        #               { "rho" => 0,
        #                 "vega" => 0,
        #                 "theta" => 0,
        #                 "delta" => 0,
        #                 "gamma" => 0,
        #                 "iv" => 0,
        #                 "currentValue" => false } },
        #         "Product" =>
        #           { "symbol" => "IBM",
        #             "securityType" => "OPTN",
        #             "callPut" => "CALL",
        #             "expiryYear" => 2021,
        #             "expiryMonth" => 12,
        #             "expiryDay" => 17,
        #             "strikePrice" => 100.0 } }
        #
        class Response
          include TTK::Containers::Quote::ComposedMethods
          include TTK::Containers::Product::Forward

          # Used by other containers when a Quote object is required; sets up a nice
          # empty object
          def self.null_quote(product:)
            h = { "dateTimeUTC" => 0, "quoteStatus" => "DELAYED",
                  "Product" => {},
                  "Option" => {
                    "ask" => 0, "bid" => 0, "daysToExpiration" => 0,
                    "lastTrade" => 0, "openInterest" => 0, "intrinsicValue" => 0,
                    "timePremium" => 0, "symbolDescription" => "Null quote",
                    "OptionGreeks" => {}
                  } }
            h["Product"].merge!(product)
            og = { "rho" => 0.001, "vega" => 0.001, "theta" => -0.001,
                   "delta" => 0.001, "gamma" => 0.001, "iv" => 0.001, "currentValue" => false }
            og["delta"] = -0.001 if product["callPut"] == "PUT"
            h['Option']['OptionGreeks'].merge!(og)
            new(body: h)
          end

          UnknownMarketQuoteType = Class.new(StandardError)

          attr_reader :body, :detail, :product

          def initialize(body:)
            @body = body
            @product = ETrade::Containers::Product.new(body.dig("Product"))

            @detail = if body.key?("Intraday")
                        body.dig("Intraday")
                      elsif body.key?("Option")
                        body.dig("Option")
                      end
          end

          def update_quote(*)
            # no op since Response bodies never get updated in this container
            # we always allocate new ones
            nil
          end

          def quote_timestamp
            Eastern_TZ.to_local(Time.at(body.dig("dateTimeUTC") || 0))
          end

          def quote_status
            body.dig("quoteStatus").downcase.to_sym
          end

          def ask
            detail.dig("ask")
          end

          def bid
            detail.dig("bid")
          end

          def last
            detail.dig("lastTrade")
          end

          def volume
            detail.dig("totalVolume")
          end

          def dte
            return 0 unless equity_option?
            detail.dig("daysToExpiration")
          end

          def open_interest
            return 0 unless equity_option?
            detail.dig("openInterest")
          end

          def intrinsic
            return 0.0 unless equity_option?
            detail.dig("intrinsicValue")
          end

          def extrinsic
            return 0.0 unless equity_option?
            detail.dig("timePremium")
          end

          def multiplier
            return 1 unless equity_option?
            detail.dig("optionMultiplier")
          end

          def delta
            return 0.0 unless equity_option?
            detail.dig("OptionGreeks", "delta")
          end

          def theta
            return 0.0 unless equity_option?
            detail.dig("OptionGreeks", "theta")
          end

          def gamma
            return 0.0 unless equity_option?
            detail.dig("OptionGreeks", "gamma")
          end

          def vega
            return 0.0 unless equity_option?
            detail.dig("OptionGreeks", "vega")
          end

          def rho
            return 0.0 unless equity_option?
            detail.dig("OptionGreeks", "rho")
          end

          def iv
            return 0.0 unless equity_option?
            detail.dig("OptionGreeks", "iv")
          end
        end
      end
    end
  end
end
