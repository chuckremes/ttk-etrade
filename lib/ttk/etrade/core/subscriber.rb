require 'forwardable'

# Included by any class that wants to subscribe for quote updates.
# This module contains all the methods necessary to receive a
# quote update, assign it to local storage, and make it available
# for the object to use.
#
module TTK::ETrade::Core::Quotes::Subscriber
  #not sure this is the best way to do this...
  # need this module to forward bid/ask/last/volume/
  # etc to @quote. need to test that this can all be setup
  # in a module and then included by other classes where
  # it just works. test it!
  extend Forwardable
  def_delegators :@quote,
                 :bid,
                 :ask,
                 :last,
                 :volume,
                 :open_interest,
                 :dte,
                 :intrinsic,
                 :extrinsic,
                 :delta,
                 :gamma,
                 :theta,
                 :vega,
                 :rho,
                 :iv,
                 :quote_timestamp,
                 :quote_status

  # Callback method to receive a quote update
  #
  def update_quote(from_quote:)
    @quote   = from_quote
  end

  # Knows how to collect the relevant local data and establish
  # a subscription.
  #
  # +self+ takes on the value of the object instance that includes
  # this module.
  #
  def subscribe(quotes, cycle: :once, type: nil)
    type = if equity?
             :equity
           elsif equity_option?
             :equity_option
           end
    quotes.subscribe(symbol: osi, type: type, cycle: cycle, observer: self)
  end
end

