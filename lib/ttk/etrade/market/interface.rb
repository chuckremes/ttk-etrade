require "async"
require "async/barrier"
require "async/limiter/window/sliding"

class TTK::ETrade::Market::Interface
  include Enumerable # used to enumerate output of #list only

  def initialize(config:, api_session:)
    @config = config
    @api_session = api_session

    # Maintain all of these Session objects here so we have a centralized
    # location to enforce a rate limiter
    @quote = TTK::ETrade::Session::Market::Quote.new(api_session: api_session)

    # According to ETrade API v0 docs, the Account APIs can be called
    # at a rate of 2 per second or 7000 per hour. Not sure if it
    # applies to the v1 API (which this implements) but it"s a good
    # baseline.
    @barrier = Async::Barrier.new
    @limiter = Async::Limiter::Window::Sliding.new(8, window: 1, parent: @barrier)
  end

  # Calls the orders list API and gets back a list of orders in various
  # states such as open, cancelled, executed, and others.
  #
  # Passing +nil+ for +status+ will force load all order statuses such as
  # cancelled, rejected, etc.
  #
  def list(status = nil)
    array = []
    marker = nil
    count = 0

    begin
      count += 1
      # only fetches 25 orders at a time, so we may get a marker back
      # when we do, then call again and accumulate the response arrays
      response, marker = @list.reload(account_key: @account.key,
                                      marker: marker)
      array += response
    end until marker.nil? || count > 100

    raise "Holy cow, fetched positions 100 times!!!" if count > 100

    array.map! { |quote_data| TTK::ETrade::Market::Containers::Response.new(body: quote_data) }
         .map! do |response|
      TTK::ETrade::Market::Containers::Quote.choose_type(interface: self, body: response)
    end
  end

  def each(&blk)
    list(nil).each { |e| yield(e) }
  end

  def empty_quote(type)
    case type
    when :equity then TTK::ETrade::Market::Quote::Equity.new
    when :equity_option then TTK::ETrade::Market::Quote::EquityOption.new
    end
  end

  def equity_quote(symbols)
    quotes = quote(symbols, { detailFlag: "INTRADAY" })
    wrap(quotes: quotes, klass: TTK::ETrade::Market::Quote::Equity)
  end

  def equity_option_quote(symbols)
    quotes = quote(symbols, { detailFlag: "OPTIONS" })
    wrap(quotes: quotes, klass: TTK::ETrade::Market::Quote::EquityOption)
  end

  def wrap(quotes:, klass:)
    quotes.map do |quote_data|
      klass.make(quote_data)
    end
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

end
