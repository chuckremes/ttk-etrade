# Wraps all calls to the ETrade REST API and converts
# the responses to Session::Result objects.
#
class TTK::ETrade::Session::OptionExpirations < TTK::ETrade::Session::Base

  URL = '/v1/market/optionexpiredate'

  def reload(symbol)
    params = { symbol: symbol }
    result = get(URL, query_params: params)

    error_check(result, context: {url: URL, query_params: params})

    result.value.dig('OptionExpireDateResponse', 'ExpirationDate') || []
  end
end
