require "async"
require "async/barrier"
require "async/limiter/window/sliding"

class TTK::ETrade::Portfolio::Interface
  include Enumerable # used to enumerate output of #list only

  def initialize(config:, api_session:, account:, quotes:)
    @config      = config
    @api_session = api_session
    @account     = account
    @quotes      = quotes

    # Maintain all of these Session objects here so we have a centralized
    # location to enforce a rate limiter
    @list = TTK::ETrade::Session::Portfolio::List.new(api_session: api_session)
    @list_cache  = []

    # According to ETrade API v0 docs, the Account APIs can be called
    # at a rate of 2 per second or 7000 per hour. Not sure if it
    # applies to the v1 API (which this implements) but it"s a good
    # baseline.
    @barrier = Async::Barrier.new
    @limiter = Async::Limiter::Window::Sliding.new(8, window: 1, parent: @barrier)
  end

  def refresh
    list(nil)
  end
  alias_method :reload, :refresh

  # Calls the orders list API and gets back a list of orders in various
  # states such as open, cancelled, executed, and others.
  #
  # Passing +nil+ for +status+ will force load all order statuses such as
  # cancelled, rejected, etc.
  #
  def list(status = nil)
    array = @list.reload(account_key: @account.key)

    array.map! { |element| TTK::ETrade::Portfolio::Containers::Response::Position.new(body: element, quotes: @quotes) }
    process_list(array)
    @list_cache
  end

  def each(&blk)
    list(nil).each { |e| yield(e) }
  end

  private

  attr_reader :config, :api_session

  def async_limiter
    result = nil
    Async do
      @limiter.async do
        result = yield
      end
    end
    result
  end

  def process_list(array)
    @list_cache = filter(array)
  end

  def filter(array)
    return array if config.positions.allowed_underlying.empty?
    array.select { |position| config.positions.allowed_underlying.include?(position.symbol) }
  end

end
