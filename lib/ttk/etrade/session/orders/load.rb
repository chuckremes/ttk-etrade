
#
# Thin presentation around native format.
#
class TTK::ETrade::Session::Orders::Load < TTK::ETrade::Session::Orders::Base

  def reload(order_id:, account_key:)
    url = "/v1/accounts/#{account_key}/orders/#{order_id}"
    result = get(url)
    error_check(result, context: { url: url })

    result.value.dig("OrdersResponse", "Order", 0) || {}
  end
end

