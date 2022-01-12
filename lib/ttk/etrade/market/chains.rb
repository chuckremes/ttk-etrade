require "async"
require "async/barrier"
require "async/limiter/window/sliding"

module TTK
  module ETrade
    module Market
      class Chains
        def initialize(config:, api_session:)
          @config          = config
          @api_session     = api_session
          @expirations_map = {}
          @chains_map      = {}

          # According to ETrade API v0 docs, the Market APIs can be called
          # at a rate of 4 per second or 14000 per hour. Not sure if it
          # applies to the v1 API (which this implements) but it"s a good
          # baseline.
          @barrier = Async::Barrier.new
          @limiter = Async::Limiter::Window::Sliding.new(8, window: 1, parent: @barrier)
        end

        # Gets the list of option expirations for the given +symbol+
        #
        def option_expirations(symbol)
          unless @expirations_map[symbol]
            expirations_session = TTK::ETrade::Session::OptionExpirations.new(api_session: api_session,
              limiter: @limiter, barrier: @barrier)
            array               = expirations_session.reload(symbol)

            @expirations_map[symbol] = TTK::ETrade::Market::OptionExpirations.new.update(from_array: array)
          end

          @expirations_map[symbol]
        end

        # Returns an array of Options given the +symbol+ and an array of +expirations+
        #
        def option_chains(symbol, expirations)
          unless @chains_map[symbol]
            chain_session = TTK::ETrade::Session::OptionChains.new(api_session: api_session,
              limiter: @limiter, barrier: @barrier)

            # non-async way
            # @chains_map[symbol] = expirations.inject([]) do |memo, expiration|
            #   option_chain_response = chain_session.reload(symbol, expiration)
            #   chain                 = TTK::ETrade::Options::Chain.new.update(from_hash: option_chain_response)
            #
            #   memo + chain.to_a
            # end
            STDERR.puts "Starting Async block for chains"
            Async do
              accumulator = []
              expirations.each do |expiration|
                @limiter.async do
                  option_chain_response = chain_session.reload(symbol, expiration)
                  accumulator << TTK::ETrade::Market::Chain.new.update(from_hash: option_chain_response)
                end
              end
              @barrier.wait
              STDERR.puts "chains barrier done"
              @chains_map[symbol] = accumulator.inject([]) { |memo, chain| memo + chain.to_a }
            end
            STDERR.puts "Ending Async block for chains"
          end

          @chains_map[symbol]
        end

        private

        attr_reader :config, :api_session
      end
    end
  end
end
