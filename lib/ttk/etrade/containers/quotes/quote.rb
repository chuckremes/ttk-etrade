require "forwardable"

class TTK::ETrade::Containers::Quotes::Quote
  attr_reader :product, :quote
  extend Forwardable
  def_delegators :@product,
                 :symbol,
                 :expiration_date,
                 :expiration_string,
                 :strike,
                 :callput,
                 :call?,
                 :put?,
                 :equity?,
                 :equity_option?,
                 :osi

  def self.make(quote_data)
    instance = new
    instance.update_quote(from_hash: quote_data)
    instance
  end

  def self.null(product={})
    make(
      {
        "dateTimeUTC" => 0,
        "quoteStatus" => "DELAYED",
        "ahFlag"      => "false",
        "Option"      =>
          { "ask"               => 0,
            "askSize"           => 0,
            "bid"               => 0,
            "bidSize"           => 0,
            "daysToExpiration"  => 0,
            "lastTrade"         => 0,
            "openInterest"      => 0,
            "intrinsicValue"    => 0,
            "timePremium"       => 0,
            "symbolDescription" => "Null quote",
            "OptionGreeks"      =>
              { "rho"          => 0,
                "vega"         => 0,
                "theta"        => 0,
                "delta"        => 0,
                "gamma"        => 0,
                "iv"           => 0,
                "currentValue" => false } },
        "Product"     =>
          { "symbol"       => product["symbol"] || "NULLSYMBOL",
            "securityType" => product["security_type"] || "null",
            "callPut"      => product["optionType"] || "none",
            "expiryYear"   => product["expiryYear"] || 0,
            "expiryMonth"  => product["expiryMonth"] || 0,
            "expiryDay"    => product["expiryDay"] || 0,
            "strikePrice"  => product["strikePrice"] || 0 } }
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


end
