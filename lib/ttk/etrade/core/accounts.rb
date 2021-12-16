# Load from vendor and set primary.
#
# Thin presentation around native format.
#
class TTK::ETrade::Core::Accounts < TTK::ETrade::Core::Session
  include Enumerable

  URL_PATH = "/v1/accounts/list"

  attr_reader :quotes

  def initialize(config:, api_session:, parent: nil, body: {}, reload_now: true, quotes:)
    @config      = config
    @api_session = api_session
    @parent      = parent
    @body        = body
    @quotes      = quotes
    @cache       = []
    reload(api_session) if reload_now
  end

  def reload(session_ref = api_session)
    result = get(URL_PATH)
    if result.success?
      @body = result.value
      filter(list).each { |account| create_or_reload(account) }
    else
      STDERR.puts "#{self.class}: reload failed, #{result.inspect}"
      {}
    end
    super
  end

  def accounts
    @cache
  end

  def primary
    accounts.find(TTK::ETrade::Core::NullAccount) { |account| config.accounts.primary_account_id == account.id }
  end

  # Enumerable support
  def each
    accounts.each do |account|
      yield account
    end
  end

  def inspect
    "#{self.class}: accounts.count [#{accounts.size}], primary: [#{primary}]"
  end

  private

  def list
    body.dig("AccountListResponse", "Accounts", "Account") || []
  end

  def active(accs)
    return accs unless config.accounts.active_only

    accs.select { |account| account["accountStatus"] == "ACTIVE" }
  end

  def types(accs)
    return accs if config.accounts.types.empty?

    accs.select { |account| config.accounts.types.include?(account["accountType"]) }
  end

  def institution_types(accs)
    return accs if config.accounts.institution_types.empty?

    accs.select { |account| config.accounts.institution_types.include?(account["institutionType"]) }
  end

  # Only create the Account object once. Upon creation, the Account loads itself.
  # On subsequent reloads, ask the Account instance to reload itself.
  def create_or_reload(account)
    item = @cache.find { |acc| acc.id == account["accountId"] }

    if item
      item.reload
    else
      item = TTK::ETrade::Core::Account.new(
        config: config,
        api_session: api_session,
        body: account,
        parent: self,
        quotes: quotes)
      @cache << item
    end
    item
  end

  def filter(array)
    institution_types(types(active(array)))
  end
end
