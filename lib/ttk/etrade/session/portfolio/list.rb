# Load from vendor and set primary.
#
# Thin presentation around native format.
#
class TTK::ETrade::Session::Portfolio::List < TTK::ETrade::Session::Base

  def reload(account_key:)
    array = []
    marker = nil

    while true
      params = { view: "QUICK", count: 50 }
      params.merge!(pageNumber: marker) if marker

      url = "/v1/accounts/#{account_key}/portfolio"

      result = get(url, query_params: params)
      error_check(result, context: { url: url,
                                     account_key: account_key,
                                     marker: marker,
                                     query_params: params })

      array += result.value.dig("PortfolioResponse", "AccountPortfolio", 0, "Position") || []
      marker = result.value.dig("PortfolioResponse", "AccountPortfolio", 0, "nextPageNo")
      break unless marker
    end

    array
  end
end

