# Load from vendor and set primary.
#
# Thin presentation around native format.
#
class TTK::ETrade::Session::Orders::Cancel < TTK::ETrade::Session::Orders::Base

  def submit(account_key:, payload:)
    url    = "/v1/accounts/#{account_key}/orders/cancel.json"

    pp 'cancel payload', payload
    result = put(url, Oj.dump(payload))
    error_check(result, context: { url: url,
                                   account_key: account_key,
                                   payload: payload })

    result.value.dig('CancelOrderResponse') || {}
  end
end

