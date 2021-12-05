#
# Thin presentation around native format.
#
class TTK::ETrade::Core::Balances < TTK::ETrade::Core::Session

  def initialize(config:, api_session:, parent: nil, body: {}, reload_now: true)
    @url    = "/v1/accounts/#{parent.key}/balance"
    @params = { instType: parent.institution_type.to_s.upcase, realTimeNAV: true }
    super
  end

  def settled_cash
    body.dig('BalanceResponse', 'Computed', 'settledCashForInvestment') || 0.0
  end

  def available_cash
    body.dig('BalanceResponse', 'Computed', 'cashAvailableForInvestment') || 0.0
  end

  def reserved_to_orders
    available_cash - settled_cash
  end

  def margin_buying_power
    body.dig('BalanceResponse', 'Computed', 'marginBuyingPower') || 0.0
  end

  def nav
    body.dig('BalanceResponse', 'Computed', 'RealTimeValues', 'totalAccountValue') || 0.0
  end

  def id
    body.dig('BalanceResponse', 'accountId')
  end

  def inspect
    "Balances(#{self.class}): {\n" +
      "                   id: #{id}\n" +
      "       available_cash: #{available_cash}\n" +
      "         settled_cash: #{settled_cash}\n" +
      "   reserved_to_orders: #{reserved_to_orders}\n" +
      "  margin_buying_power: #{margin_buying_power} \n" +
      "                  nav: #{nav}\n"
  end

  def reload(session_ref = api_session)
    result = get(@url, query_params: @params)
    @body  = if result.success?
               result.value
             else
               STDERR.puts "#{self.class}: reload failed, #{result.inspect}"
               {}
             end
    super
  end

  private

end
