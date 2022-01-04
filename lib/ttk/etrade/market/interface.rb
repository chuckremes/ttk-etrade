# require "async"
# require "async/barrier"
# require "async/limiter/window/sliding"

module TTK
  module ETrade
    module Market
      class Interface
        UnknownQuoteType = Class.new(StandardError)

        private attr_reader :config, :api_session, :quote

        def initialize(config:, api_session:)
          @config = config
          @api_session = api_session

          # Maintain all of these Session objects here so we have a centralized
          # location to enforce a rate limiter
          @quote = TTK::ETrade::Session::Market::Quote.new(api_session: api_session)

          # According to ETrade API v0 docs, the Account APIs can be called
          # at a rate of 2 per second or 7000 per hour. Not sure if it
          # applies to the v1 API (which this implements) but it"s a good
          # baseline.
          # @barrier = Async::Barrier.new
          # @limiter = Async::Limiter::Window::Sliding.new(8, window: 1, parent: @barrier)
        end

        # Calls the market quote API and retrieves the symbol quote. Used for retrieving
        # a single quote at a time.
        #
        def lookup_quote(symbol:, type:)
          array = if type == :equity
                    quote.lookup([symbol], detail_flag: "INTRADAY")
                  elsif type == :equity_option
                    quote.lookup([symbol], detail_flag: "OPTIONS")
                  else
                    raise UnknownQuoteType.new(type)
                  end

          array.map! { |quote_data| TTK::ETrade::Market::Containers::Response.new(body: quote_data) }.first
        end

        def lookup_quotes(symbols:)

        end
      end
    end
  end
end
