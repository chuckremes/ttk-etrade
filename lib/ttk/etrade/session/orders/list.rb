# Load from vendor and set primary.
#
# Thin presentation around native format.
#
class TTK::ETrade::Session::Orders::List < TTK::ETrade::Session::Orders::Base

  def reload(account_key:, start_date:, end_date:, marker:, status: :open)
    puts "Loading Orders from [#{start_date}] to [#{end_date}]"
    count = 25
    params = {
      fromDate: convert_date(start_date),
      toDate:   convert_date(end_date),
      count:    count }
    params.merge!(marker: marker) if marker
    params.merge!(status: status) if status

    url = "/v1/accounts/#{account_key}/orders.json"

    result = get(url, query_params: params)
    error_check(result, context: { url:          url,
                                   start_date:   convert_date(start_date),
                                   end_date:     convert_date(end_date),
                                   count:        count,
                                   marker:       marker,
                                   status:       status,
                                   query_params: params })

    array      = result.value.dig('OrdersResponse', 'Order') || []
    new_marker = result.value.dig('OrdersResponse', 'marker')
    # p 'new marker', new_marker, 'next', result.value.dig('OrdersResponse', 'next')
    # debug(url, result)
    # binding.pry
    [array, new_marker]
  end

  def convert_date(date)
    # ETrade API requires this order of values
    date.strftime("%m%d%Y")
  end
end

