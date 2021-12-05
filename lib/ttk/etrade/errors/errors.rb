
module TTK
  module ETrade
    module Errors
      # These are Account, Position, and Quote related errors.
      # The ETrade Order system reuses many of these error codes but assigns
      # different reasons. Alas, we need to know which API we are hitting
      # to lookup the error from the appropriate place.
      #
      ERRORS = {
        100 => (AccountKeyWrongForUser = Class.new(TTK::ETrade::Errors::Session)),
        102 => (InvalidAccountKey = Class.new(TTK::ETrade::Errors::Session)),
        253 => (UserUnauthorizedForAccount = Class.new(TTK::ETrade::Errors::Session)),

        300 => (TransactionServiceUnavailable = Class.new(TTK::ETrade::Errors::Session)),
        301 => (AccountLoadFailure = Class.new(TTK::ETrade::Errors::Session)),

        1001 => (InvalidTransactionID = Class.new(TTK::ETrade::Errors::Session)),
        1002 => (TransactionTypeNotPermitted = Class.new(TTK::ETrade::Errors::Session)),
        1003 => (InvalidTransactionGroup = Class.new(TTK::ETrade::Errors::Session)),
        1004 => (SecurityTypeNotPermitted = Class.new(TTK::ETrade::Errors::Session)),
        1005 => (InvalidOrderID = Class.new(TTK::ETrade::Errors::Session)),
        1007 => (SymbolFieldNotPermitted = Class.new(TTK::ETrade::Errors::Session)),
        1008 => (InvalidSecurityType = Class.new(TTK::ETrade::Errors::Session)),
        1009 => (OrderIDFieldNotPermitted = Class.new(TTK::ETrade::Errors::Session)),
        1010 => (MultipleTransactionTypesListed = Class.new(TTK::ETrade::Errors::Session)),
        1011 => (TooManyParamsInRequestURI = Class.new(TTK::ETrade::Errors::Session)),
        1012 => (TransactionGroupFieldNotPermitted = Class.new(TTK::ETrade::Errors::Session)),
        1013 => (TransactionTypeFieldNotPermitted = Class.new(TTK::ETrade::Errors::Session)),
        1014 => (StartAmountShouldBeLessThanEndAmount = Class.new(TTK::ETrade::Errors::Session)),
        1015 => (InvalidAmount = Class.new(TTK::ETrade::Errors::Session)),

        2001 => (InvalidAccountType = Class.new(TTK::ETrade::Errors::Session)),
        2002 => (InvalidDateRange = Class.new(TTK::ETrade::Errors::Session)),
        2003 => (InvalidDate = Class.new(TTK::ETrade::Errors::Session)),
        2004 => (InvalidDateFormat = Class.new(TTK::ETrade::Errors::Session)),
        2005 => (InvalidCountRange = Class.new(TTK::ETrade::Errors::Session)),
        2006 => (InvalidSortColumn = Class.new(TTK::ETrade::Errors::Session)),
        2007 => (InvalidSortOrder = Class.new(TTK::ETrade::Errors::Session)),
        2008 => (PageMarkerAndMarkerPassed = Class.new(TTK::ETrade::Errors::Session)),

        7001 => (InvalidAccount = Class.new(TTK::ETrade::Errors::Session)),
        7002 => (InvalidInstitutionType = Class.new(TTK::ETrade::Errors::Session)),

        10031 => (NoOptionsInMonth = Class.new(TTK::ETrade::Errors::Session)),
        10032 => (NoOptionsForSymbol = Class.new(TTK::ETrade::Errors::Session)),
        10033 => (InvalidSymbol = Class.new(TTK::ETrade::Errors::Session)),
        10034 => (ErrorFetchingProductDetails = Class.new(TTK::ETrade::Errors::Session)),
        10035 => (UnauthorizedForAPI = Class.new(TTK::ETrade::Errors::Session)),
        10036 => (ErrorFetchingExpirationDates = Class.new(TTK::ETrade::Errors::Session)),
        10037 => (NoStandardOptionsInMonth = Class.new(TTK::ETrade::Errors::Session)),
        10038 => (NoMiniOptionsInMonth = Class.new(TTK::ETrade::Errors::Session)),
        10039 => (MissingExpirationDate = Class.new(TTK::ETrade::Errors::Session)),
        10040 => (InvalidOptionType = Class.new(TTK::ETrade::Errors::Session)),
        10041 => (InvalidOoptionTypeInOSI = Class.new(TTK::ETrade::Errors::Session)),
        10042 => (MissingValidOptionType = Class.new(TTK::ETrade::Errors::Session)),
        10043 => (MissingSymbol = Class.new(TTK::ETrade::Errors::Session)),
        10044 => (NoOptionsForSymbolOrDate = Class.new(TTK::ETrade::Errors::Session)),
        10045 => (Top5QuotesUnavailable = Class.new(TTK::ETrade::Errors::Session)),
        10046 => (InvalidOptionCategory = Class.new(TTK::ETrade::Errors::Session)),
      }

      ERRORS.default = (UnknownErrorCode = Class.new(TTK::ETrade::Errors::Session))

      OrderError = Class.new(TTK::ETrade::Errors::Session)
      OrderWarning = Class.new(TTK::ETrade::Errors::Session)

      ORDER_ERRORS = {

      }
      ORDER_ERRORS.default = (UnknownOrderErrorCode = Class.new(OrderError))

      ORDER_WARNINGS = {
        1026 => (SuccessfulOrder = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1027 => (MarketClosedButEntered = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1036 => (AccountRestricted = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1037 => (InsufficientShares = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1040 => (CloseNonexistantPosition = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1042 => (PotentialDoubleOrder = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1043 => (TradingHaltInName = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1045 => (DangerousMarketOrder = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1064 => (OrderIncludesMoreFees = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1065 => OrderIncludesMoreFees,
        1070 => (OffsetFIFO = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1071 => (OffsetLIFO = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1072 => (OffsettMaximizeLoss = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1073 => (OffsetMaximizeGain = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1074 => (OffsetMinimizeLongTermGain = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1075 => (OffsetMinimizeShortTermGain = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1076 => (OffsetMaximizeLongTermGain = Class.new(TTK::ETrade::Errors::OrderWarning)),
        1077 => (OffsetMaximizeShortTermGain = Class.new(TTK::ETrade::Errors::OrderWarning)),

        5003 => (PendingCancelForOrderAlready = Class.new(TTK::ETrade::Errors::OrderWarning)),
      }
      # No default... should fall through to ORDER_ERRORS instead
      # ORDER_WARNINGS.default = (UnknownOrderWarningCode = Class.new(OrderWarning))

      MarketError = Class.new(TTK::ETrade::Errors::Session)
      MARKET_ERRORS = {
        163 => (QuoteServiceUnavailable = Class.new(TTK::ETrade::Errors::MarketError)),

        1002 => (ProductDetailsFetchError = Class.new(TTK::ETrade::Errors::MarketError)),
        1019 => (InvalidQuoteSymbol = Class.new(TTK::ETrade::Errors::MarketError)),
        1020 => (InvalidDetailFlag = Class.new(TTK::ETrade::Errors::MarketError)),
        1021 => (InvalidUserID = Class.new(TTK::ETrade::Errors::MarketError)),
        1023 => (InvalidQuoteCountMax25 = Class.new(TTK::ETrade::Errors::MarketError)),
        1024 => (InvalidMForMMFSymbol = Class.new(TTK::ETrade::Errors::MarketError)),
        1025 => (InvalidQuoteCountMax50 = Class.new(TTK::ETrade::Errors::MarketError)),

      }
      MARKET_ERRORS.default =(UnknownMarketErrorCode = Class.new(MarketError))
    end
  end
end
