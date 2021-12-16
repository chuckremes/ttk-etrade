require_relative "quote"

module TTK
  module ETrade
    module Containers
      module Quotes

        class EquityOption < Quote
          KEY = "Option"

          def dte
            quote.dig(self.class::KEY, "daysToExpiration")
          end
          alias_method :days_to_expiration, :dte

          def open_interest
            quote.dig(self.class::KEY, "openInterest")
          end

          def intrinsic
            quote.dig(self.class::KEY, "intrinsicValue")
          end

          def extrinsic
            quote.dig(self.class::KEY, "timePremium")
          end

          def multiplier
            quote.dig(self.class::KEY, "optionMultiplier")
          end

          def delta
            quote.dig(self.class::KEY, "OptionGreeks", "delta")
          end

          def theta
            quote.dig(self.class::KEY, "OptionGreeks", "theta")
          end

          def gamma
            quote.dig(self.class::KEY, "OptionGreeks", "gamma")
          end

          def vega
            quote.dig(self.class::KEY, "OptionGreeks", "vega")
          end

          def rho
            quote.dig(self.class::KEY, "OptionGreeks", "rho")
          end

          def iv
            quote.dig(self.class::KEY, "OptionGreeks", "iv")
          end
          alias_method :implied_volatility, :iv

          def nice_print
            separator = " | "
            puts "QuoteTS".rjust(21).ljust(22) + separator +
                   "Bid".rjust(6).ljust(7) + separator +
                   "Ask".rjust(6).ljust(7) + separator +
                   "Last".rjust(6).ljust(7) + separator +
                   "Extr".rjust(6).ljust(7) + separator +
                   "Intr".rjust(6).ljust(7) + separator +
                   "Delta".rjust(6).ljust(7) + separator +
                   "Theta".rjust(6).ljust(7) + separator
            now = self.quote_timestamp.strftime("%Y%m%d-%H:%M:%S.%L").rjust(21).ljust(22)
            bid = self.bid.to_s.rjust(6).ljust(7)
            ask = self.ask.to_s.rjust(6).ljust(7)
            last = self.last.to_s.rjust(6).ljust(7)
            extrinsic = self.extrinsic.to_s.rjust(6).ljust(7)
            intrinsic = self.intrinsic.to_s.rjust(6).ljust(7)
            delta = self.delta.to_s.rjust(6).ljust(7)
            theta = self.theta.to_s.rjust(6).ljust(7)
            # binding.pry
            puts [now, bid, ask, last, extrinsic, intrinsic, delta, theta].join(separator)
          end
        end

      end
    end
  end
end
