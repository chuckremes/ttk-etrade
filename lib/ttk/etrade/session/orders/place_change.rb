# Load from vendor and set primary.
#
# Thin presentation around native format.
#
class TTK::ETrade::Session::Orders::PlaceChange < TTK::ETrade::Session::Orders::Base

  def submit(account_key:, payload:, order_id:)
    url    = "/v1/accounts/#{account_key}/orders/#{order_id}/change/place.json"

    result = put(url, Oj.dump(payload))
    error_check(result, context: { url: url,
                                   account_key: account_key,
                                   payload: payload,
                                   order_id: order_id })

    result.value.dig("PlaceOrderResponse") || {}
  end
end

