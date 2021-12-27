# frozen_string_literal: true

# require "delegate"
require_relative '../../../../../../ttk-containers/lib/ttk/containers/leg/shared'

#
# External interface should be in sync across all containers
# so they can be used interchangeably.
#
module TTK
  module ETrade
    module Portfolio
      module Containers
        module Response
          class Position
            include TTK::Containers::Quote::Forward
            include TTK::Containers::Product::Forward
            include TTK::Containers::Leg::ComposedMethods

            attr_reader :body, :product, :quote

            def initialize(body:)
              @body = body
              @quote = NullQuote
              @product = body['Product']
            end

            def side
              body['positionType'].downcase.to_sym
            end

            def unfilled_quantity
              0
            end

            def filled_quantity
              body['quantity']
            end

            def execution_price
              body['pricePaid']
            end

            def order_price
              # not sure what to put here yet
              nil
            end

            def stop_price
              0.0
            end

            def placed_time
              TTK::Containers::Leg::EPOCH
            end

            def execution_time
              # ETrade gives us this particular date as milliseconds from epoch
              # Also, all ETrade times are Eastern timezone so convert to our
              # local TZ
              Eastern_TZ.to_local(Time.at((body['dateAcquired'] || 0) / 1000))
            end

            def preview_time
              TTK::Containers::Leg::EPOCH
            end

            def leg_status
              :open
            end

            def leg_id
              body['positionId']
            end

            def fees
              body['otherFees']
            end

            def commission
              body['commissions']
            end

            def direction
              :opening
            end
          end
        end
      end
    end
  end
end

# class TTK::ETrade::Portfolio::Containers::Response::Position < SimpleDelegator
#
#
#   def initialize(body:)
#     @body = body
#
#     super(TTK::ETrade::Orders::Containers::PositionLeg.new(@body))
#   end
# end
