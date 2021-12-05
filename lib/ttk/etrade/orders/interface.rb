require 'async'
require 'async/barrier'
require "async/limiter/window/sliding"

class TTK::ETrade::Orders::Interface
  include Enumerable # used to enumerate output of #list only

  def initialize(config:, api_session:, account:, quotes:)
    @config      = config
    @api_session = api_session
    @account     = account
    @quotes      = quotes

    # Maintain all of these Session objects here so we have a centralized
    # location to enforce a rate limiter
    @list_orders    = TTK::ETrade::Session::Orders::List.new(api_session: api_session)
    @list_cache     = []
    @load           = TTK::ETrade::Session::Orders::Load.new(api_session: api_session)
    @preview        = TTK::ETrade::Session::Orders::Preview.new(api_session: api_session)
    @preview_change = TTK::ETrade::Session::Orders::PreviewChange.new(api_session: api_session)
    @place          = TTK::ETrade::Session::Orders::Place.new(api_session: api_session)
    @place_change   = TTK::ETrade::Session::Orders::PlaceChange.new(api_session: api_session)
    @cancel         = TTK::ETrade::Session::Orders::Cancel.new(api_session: api_session)

    # According to ETrade API v0 docs, the Orders APIs can be called
    # at a rate of 2 per second or 7000 per hour. Not sure if it
    # applies to the v1 API (which this implements) but it's a good
    # baseline.
    @barrier = Async::Barrier.new
    @limiter = Async::Limiter::Window::Sliding.new(8, window: 1, parent: @barrier)
  end

  def refresh
    list(nil)
  end

  # Calls the orders list API and gets back a list of orders in various
  # states such as open, cancelled, executed, and others.
  #
  # Passing +nil+ for +status+ will force load all order statuses such as
  # cancelled, rejected, etc.
  #
  def list(status = nil)
    elapsed("ELAPSED list(#{status})") do
      array  = []
      marker = nil
      count  = 0

      begin
        count += 1
        # only fetches 25 orders at a time, so we may get a marker back
        # when we do, then call again and accumulate the response arrays
        response, marker = @list_orders.reload(account_key: @account.key,
                                               start_date:  config.orders.start_date,
                                               end_date:    config.orders.end_date,
                                               marker:      marker,
                                               status:      status)
        array            += response
      end until marker.nil? || count > 100

      raise "Holy cow, fetched orders 100 times!!!" if count > 100

      array.map! { |order_response| TTK::ETrade::Orders::Containers::Response::Existing.new(body: order_response) }
      # process_list(array)
      @list_cache = filter(array).map do |element|
        TTK::ETrade::Orders::Containers::Existing.new(interface: self, body: element, account_key: @account.key)
      end
    end
    @list_cache
  end

  def each(&blk)
    list(nil).each { |e| yield(e) }
  end

  def new_vertical_spread(body_leg:, wing_leg:)
    container = TTK::ETrade::Orders::Containers::NewTwoLeg.new(interface: self)
    container.set_legs(body_leg: body_leg,
                       wing_leg: wing_leg)
    container.set_defaults
    container
  end

  def submit_preview(payload)
    result = @preview.submit(payload: payload, account_key: @account.key)
    TTK::ETrade::Orders::Containers::Response::Preview.new(body: result)
  end

  def submit_change_preview(payload, order_id:)
    result = @preview_change.submit(payload: payload, account_key: @account.key, order_id: order_id)
    TTK::ETrade::Orders::Containers::Response::Preview.new(body: result)
  end

  def submit_order(payload)
    result = @place.submit(payload: payload, account_key: @account.key)
    TTK::ETrade::Orders::Containers::Response::Placed.new(body: result)
  end

  def submit_order_change(payload, order_id:)
    result = @place_change.submit(payload: payload, account_key: @account.key, order_id: order_id)
    TTK::ETrade::Orders::Containers::Response::Placed.new(body: result)
  end

  # How to print out #list details?
  # def inspect
  #   temp = orders.each_with_object([]) do |order, memo|
  #     memo << order
  #   end
  #   "#{self.class}: orders.count [#{orders.count}]\n" + temp.inspect
  # end

  def load_order(order_id:, account_key:)
    order = nil
    elapsed("ELAPSED load_order #{order_id}") do
        body  = @load.reload(order_id: order_id, account_key: account_key)
        order = TTK::ETrade::Orders::Containers::Response::Existing.new(body: body)
    end
    order
  end

  def cancel_order(payload:, account_key:)
    body = @cancel.submit(payload: payload, account_key: account_key)
    TTK::ETrade::Orders::Containers::Response::Cancel.new(body: body)
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
    filter(array).each do |order|
      create_or_reload(order)
    end
  end

  def filter(array)
    return array if config.orders.allowed_underlying.empty?

    array #.select { |order| config.orders.allowed_underlying.include?(order['Product']['symbol']) }
  end

  def create_or_reload(order)
    # not sure I even need this
    # the #list method wraps each element in a Response::Existing... the call to reload
    # just downloads another exact copy of what #list just returned, so that's uselss.
    # all this method does then is wrap the Response in a Container which the parent
    # could do too.
    item = @list_cache.find { |o| o.order_id == order.order_id }

    if item
      # puts "Telling container to reload itself for order_id [#{order['orderId']}]"
      item.reload
    else
      # puts "Never seen order_id [#{order['orderId']}] before, load for first time"
      item = TTK::ETrade::Orders::Containers::Existing.new(interface: self, body: order, account_key: @account.key)
      raise "somehow item is nil" if item.nil?
      @list_cache << item
    end

    nil
  end

  def elapsed(d)
    start = Time.now
    r     = yield
    e     = Time.now
    elap  = (e - start).round(1)
    puts "#{d} took [#{elap}] seconds to run"
    r
  end

end
