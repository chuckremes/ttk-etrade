# Load from vendor and set primary.
#
# Thin presentation around native format.
#
class TTK::ETrade::Session::Orders::List < TTK::ETrade::Session::Orders::Base

  def reload(account_key:, start_date:, end_date:, marker:, status: :open)
    params = { fromDate: start_date, toDate: end_date, count: 100 }
    params.merge!(marker: marker) if marker
    params.merge!(status: status) if status

    url = "/v1/accounts/#{account_key}/orders"

    result = get(url, query_params: params)
    error_check(result, context: { url:          url,
                                   start_date:   start_date,
                                   end_date:     end_date,
                                   count:        100,
                                   marker:       marker,
                                   status:       status,
                                   query_params: params })

    array      = result.value.dig('OrdersResponse', 'Order') || []
    new_marker = result.value.dig('OrdersResponse', 'marker')
    [array, new_marker]
  end
end

