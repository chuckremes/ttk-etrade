# frozen_string_literal: true

module Helper
  # Returns a struct in the form of an ETrade Product payload
  def make_etrade_product(symbol:, security_type:, callput:, year:, month:, day:, strike:)
    { "symbol" => symbol, "securityType" => security_type, "callPut" => callput,
      "expiryYear" => year, "expiryMonth" => month, "expiryDay" => day, "strikePrice" => strike}
  end

  def make_etrade_equity_product(symbol: "AAPL")
    make_etrade_product(symbol: symbol, security_type: "EQ", callput: "",
                        year: 0, month: 0, day: 0, strike: 0)
  end

  def make_etrade_option_product(symbol: "AAPL", callput: "CALL", year: 2021, month: 12, day: 17, strike: 145.5)
    make_etrade_product(symbol: symbol, security_type: "OPTN", callput: callput, year: year,
                        month: month, day: day, strike: strike)
  end

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
  def make_etrade_equity_quote(product: {})
    {
      "dateTimeUTC" => 0, "quoteStatus" => "DELAYED", "ahFlag" => "false",
      "Intraday" =>
        {"ask" => 0,
         "bid" => 0,
         "bidSize" => 0,
         "lastTrade" => 0,
         "totalVolume" => 0},
      "Product" =>
        {"symbol" => product.fetch('symbol', 'IBM'),
         "securityType" => "EQ", "callPut" => "", "expiryYear" => 0,
         "expiryMonth" => 0, "expiryDay" => 0, "strikePrice" => 0}
    }
  end

  def make_etrade_option_quote(product: {})
    h = {
      "dateTimeUTC" => 0, "quoteStatus" => "DELAYED", "ahFlag" => "false",
      "Option" =>
        {"ask" => 0,
         "bid" => 0,
         "bidSize" => 0,
         "lastTrade" => 0,
         "totalVolume" => 0,
         "daysToExpiration" => 0,
         "intrinsicValue" => 0,
         "timePremium" => 0,
         "OptionGreeks" => {
           "rho" => 0, "vega" => 0, "theta" => 0,
           "delta" => 0, "gamma" => 0, "iv" => 0, "currentValue" => false
         }
        },
      "Product" =>
        {"symbol" => product.fetch('symbol', 'IBM'),
         "securityType" => "OPTN", "callPut" => product.fetch('callPut', 'CALL'),
         "expiryYear" => 0,
         "expiryMonth" => 0, "expiryDay" => 0, "strikePrice" => 0}
    }
    # binding.pry
    h
  end

  def make_equity_product(etrade: nil)
    if etrade
      TTK::ETrade::Containers::Product.new(etrade)
    else
      # nothing yet
      nil
    end
  end

  def make_equity_quote(product: nil)
    TTK::ETrade::Market::Containers::Response.new(body: make_etrade_equity_quote)
  end
end
