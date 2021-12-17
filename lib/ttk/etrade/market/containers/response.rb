class TTK::ETrade::Market::Containers::Response

  def initialize(body:)
    @body = body

    # OrdersResponse and PlacedOrderResponse are pretty much the same except the
    # order details key has a different name in each. Accommodate both here.
    @order = if body.key?("Order")
               body.dig("Order", 0)
             elsif body.key?("OrderDetail")
               body.dig("OrderDetail", 0)
             else
               STDERR.puts "Check backtrace to see how we got here"
               raise "Never get here"
             end
  end

end

class TTK::ETrade::Core::Quote

  def self.make(quote_data)
    instance = new
    instance.update_quote(from_hash: quote_data)
    instance
  end

  def self.null(product = {})
    make(
      {
        "dateTimeUTC" => 0,
        "quoteStatus" => "DELAYED",
        "ahFlag" => "false",
        "Option" =>
          { "ask" => 0,
            "askSize" => 0,
            "bid" => 0,
            "bidSize" => 0,
            "daysToExpiration" => 0,
            "lastTrade" => 0,
            "openInterest" => 0,
            "intrinsicValue" => 0,
            "timePremium" => 0,
            "symbolDescription" => "Null quote",
            "OptionGreeks" =>
              { "rho" => 0,
                "vega" => 0,
                "theta" => 0,
                "delta" => 0,
                "gamma" => 0,
                "iv" => 0,
                "currentValue" => false } },
        "Product" =>
          { "symbol" => product["symbol"] || "NULLSYMBOL",
            "securityType" => product["security_type"] || "null",
            "callPut" => product["optionType"] || "none",
            "expiryYear" => product["expiryYear"] || 0,
            "expiryMonth" => product["expiryMonth"] || 0,
            "expiryDay" => product["expiryDay"] || 0,
            "strikePrice" => product["strikePrice"] || 0 } }
    )
  end

  def update_quote(from_quote: nil, from_hash: nil)
    # special case... when updating a Quote from another Quote
    # we need to access its internal +quote+ ivar. We make a
    # duplicate so they can potentially change indpendently.
    @quote = from_hash.nil? ? from_quote.quote.dup : from_hash
    @product = TTK::ETrade::Containers::Product.new(@quote["Product"])
  end

  def quote_timestamp
    Eastern_TZ.to_local(Time.at(quote["dateTimeUTC"] || 0))
  end

  def quote_status
    quote["quoteStatus"].downcase.to_sym
  end

  def extended_hours?
    quote["ahFlag"] == "true"
  end

  def ask
    quote.dig(self.class::KEY, "ask")
  end

  def bid
    quote.dig(self.class::KEY, "bid")
  end

  def midpoint
    if bid > 0 || ask > 0
      ((bid.to_f + ask.to_f) / 2.0).round(2, half: :down)
    else
      # handles case where it"s a non-tradeable index, e.g. VIX
      last
    end
  end

  def last
    quote.dig(self.class::KEY, "lastTrade")
  end

  def volume
    quote.dig(self.class::KEY, "totalVolume")
  end

  class Intraday < TTK::ETrade::Core::Quote
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

  class Options < TTK::ETrade::Core::Quote
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

  class All < TTK::ETrade::Core::Quote
    KEY = "All"

    def ask_time
      Eastern_TZ.to_local(Time.strptime(quote.dig(self.class::KEY, "askTime"), "%H:%M:%S %z %m-%d-%Y"))
    end

    def bid_time
      Eastern_TZ.to_local(Time.strptime(quote.dig(self.class::KEY, "bidTime"), "%H:%M:%S %z %m-%d-%Y"))
    end

    def last_Time
      Eastern_TZ.to_local(Time.at(quote.dig(self.class::KEY, "timeOfLastTrade") || 0))
    end

    def nice_print
      separator = " | "
      puts "QuoteTS".rjust(21).ljust(22) + separator +
             "Bid".rjust(6).ljust(7) + separator +
             "Ask".rjust(6).ljust(7) + separator +
             "Last".rjust(6).ljust(7) + separator
      now = self.quote_timestamp.strftime("%Y%m%d-%H:%M:%S.%L").rjust(21).ljust(22)
      b = self.bid.to_s.rjust(6).ljust(7)
      a = self.ask.to_s.rjust(6).ljust(7)
      last = self.last.to_s.rjust(6).ljust(7)
      puts [now, bid, ask, last].join(separator)
    end
  end
end
