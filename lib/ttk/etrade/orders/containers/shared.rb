module TTK
  module ETrade
    module Orders
      module Containers

        # Should be included by any container that has a Legs
        # object in it. Assumes that the container implements a #legs
        # method. Any other method not defined directly on the container
        # should be delegated or forwarded or these methods will break.
        #
        module ContainerShared # really should be for Orders... assumes #price_type and other things
          def symbol
            legs.map(&:symbol).uniq.sort.first
          end

          def products
            legs.map(&:product)
          end

          def action
            if equity?
              return :buy if long?
              return :sell if short?
              STDERR.puts "Should never get here"
              binding.pry
            elsif equity_option?
              return :buy_to_open if opening? && price_type == :debit
              return :buy_to_close if closing? && price_type == :debit
              return :sell_to_open if opening? && price_type == :credit
              return :sell_to_close if closing && price_type == :credit
              STDERR.puts "Should never get here"
              binding.pry
            else
              raise "Unhandled branch"
            end
          end

          def product_match?(other)
            # assumes legs are sorted consistently
            legs.count == other.legs.count && legs.zip(other.legs).all? do |l1, l2|
              l1.product_match?(l2)
            end
          end

          def put?
            all?(:put?)
          end

          def call?
            all?(:call?)
          end

          def equity?
            all?(:equity?)
          end

          def equity_option?
            all?(:equity_option?)
          end

          def opening?
            any?(:opening?)
          end

          def closing?
            any?(:closing?)
          end

          def short?
            all?(:short?)
          end

          def long?
            all?(:long?)
          end

          def filled_quantity
            legs.map(&:filled_quantity).sort.first
          end

          def unfilled_quantity
            legs.map(&:unfilled_quantity).sort.first
          end

          def quantity
            (filled_quantity || 0) + (unfilled_quantity || 0)
          end

          def strikes
            legs.map(&:strike)
          end

          def expiration_dates
            legs.map(&:expiration_date)
          end

          def sides
            legs.map(&:side)
          end

          def count
            legs.count
          end

          def subscribe(quotes, cycle: :once, type: nil)
            legs.each { |leg| leg.subscribe(quotes, cycle: cycle, type: type) }
          end

          def all?(field, *args)
            legs.all? { |leg| leg.send(field, *args) }
          end

          def any?(field)
            legs.any? { |leg| leg.send(field) }
          end

          def open?
            :open == status
          end

          def active?
            # :new is defined for an order we haven't downloaded yet
            [:new, :open, :cancel_requested, :partial, :individual_fills].include?(status)
          end

          def inactive?
            !active?
          end

          #
          # def nice_print
          #   separator = ' | '
          #   now = Time.now.strftime("%Y%m%d-%H:%M:%S.%L").rjust(21).ljust(22)
          #   action = self.sides.first.to_s.rjust(12).ljust(13)
          #   quantity = self.quantity.to_s.rjust(8).ljust(9)
          #   name = body_leg.osi.rjust(21).ljust(22) + " / " + wing_leg.osi.rjust(21).ljust(22)
          #   price = limit_price.to_s.rjust(5).ljust(6)
          #   term = order_term.to_s.rjust(10).ljust(10)
          #   puts [now, action, quantity, name, price, term].join(separator)
          #   legs.each(&:nice_print)
          #   nil
          # end

        end

        module ContainerGreeks
          # Greeks!
          # Defined here for aggregation across the container. Delegates to
          # each leg to get the individual greeks from a quote

          def delta
            summation(field: :delta)
          end

          def gamma
            summation(field: :gamma)
          end

          def theta
            summation(field: :theta)
          end

          def vega
            summation(field: :vega)
          end

          def rho
            summation(field: :rho)
          end

          def summation(field:)
            legs.inject(0.0) { |memo, leg| memo + leg.send(field) }
          end
        end

        # Every leg class
        module LegShared

          def subscription_status

          end

          def side
            short? ? :short : :long
          end

          def short?
            # sell_to_open is establishing a short position
            # sell_to_close is offsetting a long position with a short to close it
            !!(action.to_s =~ /sell/i)
          end

          def long?
            # buy_to_open is establishing a long position
            # buy_to_close is offsetting a short position with a long to close it
            !!(action.to_s =~ /buy/i)
          end

          def opening?
            # only works on options... need to figure out how to handle equity products
            !!(action.to_s =~ /open/)
          end

          def closing?
            # only works on options... need to figure out how to handle equity products
            !!(action.to_s =~ /close/)
          end

          def quantity
            (unfilled_quantity || 0) + (filled_quantity || 0)
          end

          def nice_print
            separator = ' | '
            now       = ''.rjust(21).ljust(22)
            action    = self.action.to_s.rjust(12).ljust(13)
            quantity  = self.quantity.to_s.rjust(8).ljust(9)
            name      = osi.rjust(46).ljust(47)
            if respond_to?(:limit_price)
              # PositionLeg
              price = limit_price.to_s.rjust(5).ljust(6)
              term  = order_term.to_s.rjust(10).ljust(10)
            else
              # OrderLeg of some kind so no specific data
              price = ''.rjust(5).ljust(6)
              term  = ''.to_s.rjust(10).ljust(10)
            end
            puts [now, action, quantity, name, price, term].join(separator)
            @quote.nice_print
            nil
          end

          def product_match?(other)
            osi == other.osi
          end
        end

        module LegGreeks
          # Greeks!
          # Defined here so each leg can adjust itself based on it
          # being a put/call and long/short
          # e.g. short put should have positive delta
          # FIXME: Needs documentation at the container level since
          # this could cause confusion in the future when computing
          # aggregate greeks for a spread. If the container uses
          # the quantity (positive and negative) for each leg then
          # that works against this logic here because the signs will
          # be flipped.

          def delta
            return super if long?
            -super
          end

          def gamma
            return super if long?
            -super
          end

          def theta
            return super if long?
            -super
          end

          def vega
            return super if long?
            -super
          end

          def rho
            return super if long?
            -super
          end
        end

        class Legs
          include Enumerable

          def self.from_instrument(array, klass: ReadOnlyLeg, order: {})
            # always sort the legs before storing
            # irb(main):109:0> a.sort_by {|a| -a.strike }.sort_by {|a| a.expiration }
            # =>
            # [#<struct O strike=500, expiration=#<Date: 2021-11-27 ((2459546j,0s,0n),+0s,2299161j)>>,
            #  #<struct O strike=410, expiration=#<Date: 2021-11-27 ((2459546j,0s,0n),+0s,2299161j)>>,
            #  #<struct O strike=500, expiration=#<Date: 2021-12-03 ((2459552j,0s,0n),+0s,2299161j)>>,
            #  #<struct O strike=410, expiration=#<Date: 2021-12-03 ((2459552j,0s,0n),+0s,2299161j)>>]
            #
            legs     = array.map { |leg| klass.new(leg, order: order) }
                            .sort_by { |leg| -leg.strike }
                            .sort_by { |leg| leg.expiration_date }
            instance = new(legs)
            instance
          end

          def self.from_position(body, klass: PositionLeg)
            from_instrument(Array(body), klass: klass)
          end

          def initialize(array)
            @array = Array(array)
          end

          def each(&blk)
            @array.each { |leg| yield(leg) }
          end
        end

        class PositionLeg
          include LegShared # several methods are overridden, see below

          extend Forwardable
          def_delegators :@product,
                         :symbol,
                         :expiration_date,
                         :expiration_string,
                         :strike,
                         :callput,
                         :call?,
                         :put?,
                         :equity?,
                         :equity_option?,
                         :osi,
                         :to_product
          # next include handles all forwarding to @quotes to get greeks and such
          include TTK::ETrade::Core::Quotes::Subscriber
          # order is important... LegGreeks calls #super to get greeks from Subscriber
          include LegGreeks

          def initialize(body, order: {})
            @body    = body
            @order   = order # not used!
            @product = TTK::ETrade::Core::Product.new(body['Product'])

            @quote = if @product.equity?
                       TTK::ETrade::Core::Quote::Intraday.null(body['Product']) # null object pattern
                     else
                       TTK::ETrade::Core::Quote::Options.null(body['Product']) # null object pattern
                     end
          end

          def position_id
            body['positionId']
          end

          alias_method :order_id, :position_id # necessary for #same? check

          def status
            :open
          end

          def date_acquired
            # ETrade gives us this particular date as milliseconds from epoch
            # Also, all ETrade times are Eastern timezone so convert to our
            # local TZ
            Eastern_TZ.to_local(Time.at((body['dateAcquired'] || 0) / 1000))
          end

          alias_method :execution_time, :date_acquired
          alias_method :place_time, :date_acquired

          def limit_price
            body['pricePaid']
          end

          def stop_price
            nil
          end

          def filled_quantity
            body['quantity']
          end

          alias_method(:quantity, :filled_quantity)

          def unfilled_quantity
            0
          end

          def last_price
            body.dig('Quick', 'lastTrade')
          end

          def commission
            body['commissions']
          end

          def fees
            body['otherFees']
          end

          def type
            body['positionType'].downcase.to_sym
          end

          def action
            case type
            when :long then :buy
            when :short then :sell
            end
          end

          def order_term
            :unknown
          end

          # OVERRIDE LegShared module

          def opening?
            # by definition, a *position* is "opening"... if it had been offset
            # to close, then it wouldn't show up as a position at all
            true
          end

          def closing?
            false
          end

          # end OVERRIDE LegShared module

          private attr_reader :body
        end

        class ReadOnlyLeg
          include LegShared

          extend Forwardable
          def_delegators :@product,
                         :symbol,
                         :expiration_date,
                         :expiration_string,
                         :strike,
                         :callput,
                         :call?,
                         :put?,
                         :equity?,
                         :equity_option?,
                         :osi,
                         :to_product
          # next include handles all forwarding to @quotes to get greeks and such
          include TTK::ETrade::Core::Quotes::Subscriber
          include LegGreeks

          attr_reader :product

          def initialize(body, order:)
            @body    = body
            @order   = order
            @product = TTK::ETrade::Core::Product.new(body['Product'])

            @quote = if @product.equity?
                       TTK::ETrade::Core::Quote::Intraday.null(body['Product']) # null object pattern
                     else
                       TTK::ETrade::Core::Quote::Options.null(body['Product']) # null object pattern
                     end
          end

          def action
            @action ||= case body['orderAction']
                        when 'BUY_OPEN' then :buy_to_open
                        when 'SELL_OPEN' then :sell_to_open
                        when 'BUY_CLOSE' then :buy_to_close
                        when 'SELL_CLOSE' then :sell_to_close
                        when 'BUY' then :buy
                        when 'SELL' then :sell
                        end
          end

          def unfilled_quantity
            return 0 unless body['orderedQuantity']
            body['orderedQuantity'] - filled_quantity
          end

          def filled_quantity
            body['filledQuantity']
          end

          def commission
            body['estimatedCommission']
          end

          def fees
            body['estimatedFees']
          end

          def limit_price
            # by definition, an ETrade order does not track price per leg
            # to get this info you need to back into it via the order_id of
            # the parent order and match it against the Position and PositionLots
            # data gathered elsewhere
            0
          end

          def order_term
            order.dig('orderTerm')
          end

          def execution_time
            Eastern_TZ.to_local(Time.at((order.dig('executedTime') || 0) / 1000))
          end

          # def pretty_print
          #   "Order(#{self.class}):" +
          #     "          action: #{action}\n" +
          #     "unfilled_quantity: #{unfilled_quantity}\n" +
          #     "  filled_quantity: #{filled_quantity}\n" +
          #     "       commission: #{commission}\n" +
          #     "             fees: #{fees}\n" + product.inspect
          # end

          private attr_reader :body, :order
        end

      end
    end
  end
end
