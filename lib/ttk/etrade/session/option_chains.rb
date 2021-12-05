# Wraps all calls to the ETrade REST API and converts
# the responses to Session::Result objects.
#
class TTK::ETrade::Session::OptionChains < TTK::ETrade::Session::Base
  URL = '/v1/market/optionchains'

  def reload(symbol, expiration)
    params = {
      symbol: symbol,
      expiryYear: expiration.year,
      expiryMonth: expiration.month,
      expiryDay: expiration.day,
      includeWeekly: true,
      chainType: 'CALLPUT',
    }
    result = get(URL, query_params: params)
    error_check(result, context: { symbol: symbol, expiration: expiration, query_params: params })

    result.value.dig('OptionChainResponse')
  end
end
