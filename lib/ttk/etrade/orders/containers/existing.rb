require "forwardable"

# Replaces the original "Container" class. This wraps the output
# of a OrdersResponse which we get from an established order.
# These are downloaded via the `orders/#{order_id}` path.
#
# Order price and probably term can be changed here. Structure
# of legs can"t be changed once established.
#
# When this order is loaded, it uses the body from the OrdersResponse
# which is the Order + OrderDetail. We should be able to change the
# price and term and resubmit, so it needs to handle PreviewOrderResponse
# and PlaceOrderResponse just like the NewOrder logic. Lots of overlap
# so maybe these are all the same thing?
#
# Wehn we make a change, we need to switch this container from using the
# ReadOnly Order and switch to using the same guts as the NewOrder. That makes
# no sense... when loading the order, we should preload it into the NewOrder
# structure so the changes can be made.
#
# Here"s the sequence for changing an existing order.
# 1. Download order, comes in as OrdersResponse with an Order + OrderDetail payload
# 2. Wrap into a OrderResponse
# 3. Put into a Containers::Existing
# 4. Change limit price which executes a method on Existing container.
# 5. Method creates a NewOrder and prefills it. Needs to get quotes for the legs.
# 6. This is returned back to an ivar in the Existing order. Any further changes
#    modifies this NewOrder.
# 7. To submit, the Existing order #submit method executes which previews the new
#    order. If successful, the Existing OrderId is used to execute a orders/{order_id}/
#    change/place API call. The old order ID will no longer be valid once this is
#    accepted.
# 8. The Existing order is no longer valid. The #submit method should have returned a
#    new Existing order.
#
class TTK::ETrade::Orders::Containers::Existing
  include TTK::ETrade::Orders::Containers::ContainerShared
  include TTK::ETrade::Orders::Containers::ContainerGreeks
  extend Forwardable
  def_delegators :@body,
                 :order_id,
                 :order_value,
                 :placed_time,
                 :execution_time,
                 :limit_price,
                 :stop_price,
                 :status,
                 :order_term,
                 :market_session,
                 :price_type,
                 :order_type,
                 :legs # ContainerShared will use this

  attr_reader :body, :interface

  def initialize(interface:, body:, account_key:)
    @interface   = interface
    @body        = body
    @account_key = account_key
    update(from_hash: body)
  end

  def reload
    if active?
      # Calls back into interface to get the information and update itself
      STDERR.puts "Reloading order #{order_id}"
      data = interface.load_order(order_id: order_id, account_key: @account_key)
      update(from_hash: data)
    else
      # STDERR.puts "#{order_id} is inactive, status [#{status}], price [#{limit_price}]"
    end
  end

  def subscription_status
    puts "was_subscribed #{was_subscribed.inspect}"
  end

  def update(from_hash:)
    @body = if from_hash.is_a?(Hash)
              TTK::ETrade::Orders::Containers::Response::Existing.new(body: from_hash)
            else
              from_hash # already wrapped in a Response class
            end
    self
  end

  def same?(other)
    order_id == other&.order_id
  rescue NoMethodError => e
    binding.pry
    pp "failed check in same?", "other", other
    pp "self", self
    raise
  end

  # ########## Change Order ############
  # These methods are involved in changing this existing order.
  # Approach is to create an internal copy of this order as a
  # New Order and then these methods will operate on it. Then we expose
  # methods to preview and submit this new order. At no point does
  # this existing order actually change; it"s Read Only.
  # #########

  def limit_price=(value)
    new_order             = find_or_create_new_order
    new_order.limit_price = value
  end

  def stop_price=(value)
    new_order            = find_or_create_new_order
    new_order.stop_price = value
  end

  def quantity=(value)
    new_order          = find_or_create_new_order
    new_order.quantity = value
  end

  def market_session=(value)
    new_order                = find_or_create_new_order
    new_order.market_session = value
  end

  def find_or_create_new_order
    unless @new_order
      order = case count
              when 1 then TTK::ETrade::Orders::Containers::NewOneLeg.new(interface: interface)
              when 2 then TTK::ETrade::Orders::Containers::NewTwoLeg.new(interface: interface)
              end
      order.set_legs(legs: legs)
      order.limit_price = limit_price
      order.stop_price  = stop_price
      order.action      = action
      order.quantity    = quantity
      order.order_type  = order_type
      order.price_type  = price_type
      @new_order        = order
    end

    @new_order
  end

  # Calls the Interface to submit a preview order
  #
  def submit_preview
    structure = find_or_create_new_order.to_preview
    # pp structure
    @preview = interface.submit_change_preview(structure, order_id: order_id)
  rescue TTK::ETrade::Errors::OrderWarning => e
    # some warnings are more important than others, but for the most
    # part we just want to record it happened otherwise it"s not an error

    @preview_warning = e
  rescue TTK::ETrade::Errors::OrderError => e
    # any errors thrown by the API should get wrapped and captured here
    # Use Null Object pattern with a Null Error to handle the common case
    @preview_error = e
  end

  # Parses the result of an earlier call to #submit_preview and returns
  # true or false depending on the warnings and errors returned.
  #
  def preview_ok?
    !(@preview_error&.failure?) && !(@preview_warning&.failure?)
  end

  def submit
    structure = find_or_create_new_order.to_place(@preview)

    pp "place structure", structure
    @placed = interface.submit_order_change(structure, order_id: order_id)
    puts "new order id = " + @placed.order_id.to_s
    @new_order = nil # now get rid of it, can"t use it a second time... is this right?
    # maybe we need to prevent an Existing order from being resubmitted more than once
    # ... yeah, that"s probably better
    # pp "placed response", @placed
    self.class.new(body: @placed,
                   interface: interface,
                   account_key: @account_key)
  end

  def submit_ok?
    true
  end

  def cancel(reason: :none)
    STDERR.puts "Cancel for reason #{reason}"
    interface.cancel_order(
      payload:     to_cancel,
      account_key: @account_key)
  end

  def to_cancel
    {
      "CancelOrderRequest" => {
        "orderId" => order_id
      }
    }
  end

  # ############# Change Order #########

end
