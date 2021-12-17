# for ComposedMethods
# temporary until ttk-containers is made into a real gem
require_relative "../../../../../../ttk-containers/lib/ttk/containers/quotes/quote/shared"

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
          UnknownMarketQuoteType = Class.new(StandardError)

          def self.choose_type(body)
            if body.key?("Intraday")
              Equity.new(body: body)
              elsif body.key?("Option")
              EquityOption.new(body: body)
            else
              raise UnknownMarketQuoteType.new(body)
            end
          end

          attr_reader :body, :detail, :product

          def initialize(body:)
            @body = body
            @product = ETrade::Containers::Product.new(body.dig("Product"))
          end

          def update_quote(*args)
            # no op since Response bodies never get updated in this container
            # we always allocate new ones
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
        end

        class Equity < Response
          include TTK::Containers::Quotes::Quote::Equity::ComposedMethods
          include TTK::Containers::Product::Forward

          def initialize(body:)
            super
            @detail = body.dig("Intraday")
          end
        end

        class EquityOption < Response
          include TTK::Containers::Quotes::Quote::EquityOption::ComposedMethods
          include TTK::Containers::Product::Forward

          def initialize(body:)
            super
            @detail = body.dig("Option")
          end

          def dte
            detail.dig("daysToExpiration")
          end

          def open_interest
            detail.dig("openInterest")
          end

          def intrinsic
            detail.dig("intrinsicValue")
          end

          def extrinsic
            detail.dig("timePremium")
          end

          def multiplier
            detail.dig("optionMultiplier")
          end

          def delta
            detail.dig("OptionGreeks", "delta")
          end

          def theta
            detail.dig("OptionGreeks", "theta")
          end

          def gamma
            detail.dig("OptionGreeks", "gamma")
          end

          def vega
            detail.dig("OptionGreeks", "vega")
          end

          def rho
            detail.dig("OptionGreeks", "rho")
          end

          def iv
            detail.dig("OptionGreeks", "iv")
          end
        end

      end
    end
  end
end
