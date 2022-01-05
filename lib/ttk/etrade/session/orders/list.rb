# Load from vendor and set primary.
#
# Thin presentation around native format.
#
class TTK::ETrade::Session::Orders::List < TTK::ETrade::Session::Orders::Base

  def reload(account_key:, start_date:, end_date:, status: :open)
    puts "Loading Orders from [#{start_date}] to [#{end_date}]"
    count = 25
    marker = nil
    array = []

    while true
      params = {
        fromDate: convert_date(start_date),
        toDate: convert_date(end_date),
        count: count }
      params.merge!(marker: marker) if marker
      params.merge!(status: status) if status

      url = "/v1/accounts/#{account_key}/orders.json"

      result = get(url, query_params: params)
      error_check(result, context: { url: url,
                                     start_date: convert_date(start_date),
                                     end_date: convert_date(end_date),
                                     count: count,
                                     marker: marker,
                                     status: status,
                                     query_params: params })

      array += result.value.dig("OrdersResponse", "Order") || []
      marker = result.value.dig("OrdersResponse", "marker")
      break unless marker
    end

    array
  end

  def convert_date(date)
    # ETrade API requires this order of values
    date.strftime("%m%d%Y")
  end
end

