require_relative "quote"

module TTK
  module ETrade
    module Containers
      module Quotes

        class Equity < Quote
          KEY = "Intraday"

          def nice_print
            separator = "|"
            puts "QuoteTS".rjust(22).ljust(23) + separator +
                   "Bid".rjust(8).ljust(9) + separator +
                   "Ask".rjust(8).ljust(9) + separator +
                   "Last".rjust(8).ljust(9) + separator
            now = self.quote_timestamp.strftime("%Y%m%d-%H:%M:%S.%L").rjust(22).ljust(23)
            b = self.bid.to_s.rjust(8).ljust(9)
            a = self.ask.to_s.rjust(8).ljust(9)
            l = self.last.to_s.rjust(8).ljust(9)
            puts [now, b, a, l].join(separator)
          end
        end

      end
    end
  end
end
