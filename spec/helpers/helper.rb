# frozen_string_literal: true

module Helper
  # Returns a struct in the form of an ETrade Product payload
  def make_etrade_product(symbol:, security_type:, callput:, year:, month:, day:, strike:)
    {"symbol" => symbol, "securityType" => security_type, "callPut" => callput,
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
        {"symbol" => product.fetch("symbol", "IBM"),
         "securityType" => "EQ", "callPut" => "", "expiryYear" => 0,
         "expiryMonth" => 0, "expiryDay" => 0, "strikePrice" => 0}
    }
  end

  def make_etrade_option_quote(product: {})
    {
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
         }},
      "Product" =>
        {"symbol" => product.fetch("symbol", "IBM"),
         "securityType" => "OPTN", "callPut" => product.fetch("callPut", "CALL"),
         "expiryYear" => 0,
         "expiryMonth" => 0, "expiryDay" => 0, "strikePrice" => 0}
    }
    # binding.pry
  end

  def make_etrade_orders_response(market_session: :regular, all_or_none: true, price_type: :credit,
    limit_price: 0.0, stop_price: 0.0, order_term: :day, order_id: rand(999_999))
    market_session = case market_session
                     when :regular then "REGULAR"
                     when :extended then "EXTENDED"
                     else "REGULAR"
    end
    price_type = case price_type
                 when :credit then "NET_CREDIT"
                 when :debit then "NET_DEBIT"
                 when :even then "NET_EVEN"
                 else "LIMIT"
    end
    order_term = case order_term
                 when :day then "GOOD_FOR_DAY"
                 when :gtc then "GOOD_UNTIL_CANCEL"
    end
    {"orderId" => order_id,
     "details" =>
        "https://api.etrade.com/v1/accounts/m2moDkzv9luKvq-AXpWGMA/orders/#{order_id}",
     "orderType" => "SPREADS",
     "OrderDetail" =>
        [{"placedTime" => 1635431118673,
          "orderValue" => 428.9736,
          "status" => "OPEN",
          "orderTerm" => order_term,
          "priceType" => price_type,
          "limitPrice" => limit_price,
          "stopPrice" => 0,
          "marketSession" => market_session,
          "allOrNone" => all_or_none,
          "netPrice" => 0,
          "netBid" => 0,
          "netAsk" => 0,
          "gcd" => 0,
          "ratio" => "",
          "Instrument" =>
             [{"symbolDescription" => "SPY Nov 10 '21 $457 Put",
               "orderAction" => "SELL_OPEN",
               "quantityType" => "QUANTITY",
               "orderedQuantity" => 1,
               "filledQuantity" => 0.0,
               "estimatedCommission" => 0.5142,
               "estimatedFees" => 0.0,
               "Product" =>
                  {"symbol" => "SPY",
                   "securityType" => "OPTN",
                   "callPut" => "PUT",
                   "expiryYear" => 2021,
                   "expiryMonth" => 11,
                   "expiryDay" => 10,
                   "strikePrice" => 457,
                   "productId" =>
                      {"symbol" => "SPY---211110P00457000", "typeCode" => "OPTION"}}},
               {"symbolDescription" => "SPY Nov 10 '21 $424 Put",
                "orderAction" => "BUY_OPEN",
                "quantityType" => "QUANTITY",
                "orderedQuantity" => 1,
                "filledQuantity" => 0.0,
                "estimatedCommission" => 0.5122,
                "estimatedFees" => 0.0,
                "Product" =>
                   {"symbol" => "SPY",
                    "securityType" => "OPTN",
                    "callPut" => "PUT",
                    "expiryYear" => 2021,
                    "expiryMonth" => 11,
                    "expiryDay" => 10,
                    "strikePrice" => 424,
                    "productId" =>
                       {"symbol" => "SPY---211110P00424000", "typeCode" => "OPTION"}}}]}]}
  end

  def make_etrade_instrument(side: :long, direction: :opening, quantity: 1, symbol: "AAPL",
    callput: "PUT", strike: 450.0, execution_price: nil)

    action_side = side == :long ? "BUY" : "SELL"
    action_direction = direction == :opening ? "OPEN" : "CLOSE"
    action = "#{action_side}_#{action_direction}"

    {"symbolDescription" => "SPY Nov 10 '21 $457 Put",
     "orderAction" => action,
     "quantityType" => "QUANTITY",
     "orderedQuantity" => quantity,
     "filledQuantity" => 0.0,
     "estimatedCommission" => 0.5142,
     "estimatedFees" => 0.0,
     "averageExecutionPrice" => execution_price,
     "Product" =>
       {"symbol" => "SPY",
        "securityType" => "OPTN",
        "callPut" => callput,
        "expiryYear" => 2021,
        "expiryMonth" => 11,
        "expiryDay" => 10,
        "strikePrice" => strike,
        "productId" =>
          {"symbol" => "SPY---211110P00457000", "typeCode" => "OPTION"}}}
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
