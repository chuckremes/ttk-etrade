# Load from vendor and set primary.
#
# Thin presentation around native format.
#
class TTK::ETrade::Session::Orders::Place < TTK::ETrade::Session::Orders::Base

  def submit(account_key:, payload:)
    url    = "/v1/accounts/#{account_key}/orders/place.json"

    payload = payload.is_a?(String) ? payload : Oj.dump(payload)
    result = post(url, payload)
    debug(url, result)
    error_check(result, context: { url: url,
                                   account_key: account_key,
                                   payload: payload })

    result.value.dig('PlaceOrderResponse') || {}
  end
end

