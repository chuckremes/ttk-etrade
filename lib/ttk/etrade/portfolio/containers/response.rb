require 'delegate'

#
# External interface should be in sync across all containers
# so they can be used interchangeably.
#
class TTK::ETrade::Portfolio::Containers::Response::Position < SimpleDelegator

  def initialize(body:)
    @body = body

    super(TTK::ETrade::Orders::Containers::PositionLeg.new(@body))
  end
end
