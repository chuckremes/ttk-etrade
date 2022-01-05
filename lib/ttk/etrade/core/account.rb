#
# Thin presentation around native format.
#
class TTK::ETrade::Core::Account < TTK::ETrade::Core::Session
  UnknownType            = Class.new(StandardError)
  UnknownInstitutionType = Class.new(StandardError)
  UnknownStatus          = Class.new(StandardError)

  attr_reader :balances, :positions, :orders, :quotes

  def self.type(code)
    case code
    when "CUSTODIAL" then :custodial
    when "CONTRIBUTORY" then :contributory
    when "INDIVIDUAL_K" then :solo_401k
    else
      STDERR.puts "code (#{code}) == 'CONTRIBUTORY' => #{code == 'CONTRIBUTORY'}"
      raise UnknownType.new("code: #{code.inspect}")
    end
  end

  def self.institution_type(code)
    case code
    when "BROKERAGE" then :brokerage
    else
      raise UnknownInstitutionType.new("code: #{code.inspect}")
    end
  end

  def self.status(code)
    case code
    when "ACTIVE" then :active
    when "CLOSED" then :closed
    else
      raise UnknownStatus.new("code: #{code.inspect}")
    end
  end

  def initialize(config:, api_session:, parent: nil, body: {}, reload_now: true, quotes:)
    @config      = config
    @api_session = api_session
    @parent      = parent
    @body        = body
    @quotes      = quotes
    @cache       = []
    reload(api_session) if reload_now
  end

  def id
    body["accountId"]
  end

  def key
    body["accountIdKey"]
  end

  def name
    body["accountName"]
  end

  def active?
    self.class.status(body["accountStatus"]) == :active
  end

  def type
    self.class.type(body["accountType"])
  end

  def institution_type
    self.class.institution_type(body["institutionType"])
  end

  def reload(session_ref = api_session)
    reload_balances(session_ref)
    reload_positions(session_ref)
    reload_orders(session_ref)
    super
  end

  # def inspect
  #   "#{self.class}: id: #{id}, key: #{key}, name: #{name}, type: #{type}, institution_type: #{institution_type}, active?: #{active?}\n" +
  #     balances.inspect + "\n" +
  #     positions.inspect + "\n" +
  #     orders.list.inspect
  #   # orders.inspect
  # end

  private

  def reload_balances(session)
    if @balances
      @balances.reload
    else
      @balances = TTK::ETrade::Core::Balances.new(config: config, api_session: api_session, parent: self)
    end
  end

  def reload_positions(session)
    if @positions
      @positions.reload
    else
      # @positions = TTK::ETrade::Core::Positions.new(config: config, api_session: api_session, parent: self)
      @positions = TTK::ETrade::Portfolio::Interface.new(
        config:      config,
        api_session: api_session,
        account:     self,
        quotes:      quotes)
    end
  end

  def reload_orders(session)
    if @orders
      # @orders.reload
      @orders.list
    else
      # @orders = TTK::ETrade::Core::Orders.new(config: config, api_session: api_session, parent: self)
      @orders = TTK::ETrade::Orders::Interface.new(
        config:      config,
        api_session: api_session,
        account:     self,
        quotes:      quotes)
    end
  end
end

class TTK::ETrade::Core::Account::Null
  def id()
    ; "null";
  end

  def key()
    ; "null";
  end

  def name()
    ; "null";
  end

  def active?()
    ; false;
  end

  def type()
    ; "null";
  end

  def institution_type()
    ; "null";
  end
end

TTK::ETrade::Core::NullAccount = TTK::ETrade::Core::Account::Null.new
