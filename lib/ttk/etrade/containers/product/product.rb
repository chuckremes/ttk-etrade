require_relative "expiration"

# for ComposedMethods
# temporary until ttk-containers is made into a real gem
require_relative "../../../../../../ttk-containers/lib/ttk/containers/product/shared"

class TTK::ETrade::Containers::Product
  include TTK::Containers::Product::ComposedMethods

  # Defined as the EPOCH
  NULL_EXPIRATION = Expiration.null

  def initialize(hash)
    @body = hash
    @expiration = Expiration.new(hash)
  end

  def security_type
    case raw_security_type
    when "OPTN" then :equity_option
    when "EQ" then :equity
    when "INDX" then :equity
    else
      raise "Unknown Product type from #{@body.inspect}, revise list!"
    end
  end

  def raw_security_type
    @body["securityType"]
  end

  def callput
    convert_callput(@body["callPut"]) || :not_option
  end

  def strike
    return @body["strikePrice"].to_f if equity_option?
    0.0
  end

  def symbol
    @body["symbol"]
  end

  def expiration_string
    @expiration.iso8601
  end

  def expiration
    return @expiration if equity_option?
    NULL_EXPIRATION
  end

  # def inspect
  #   "#{self.class}: \n" \
  #     "                  symbol: #{symbol}\n" \
  #     "              expiration: #{expiration_string}\n" \
  #     "                 callput: #{callput}\n" \
  #     "                  strike: #{strike}\n"
  # end

  def to_product
    @body.dup
  end

  private

  def convert_callput(cp)
    case cp
    when "PUT", :put
      :put
    when "CALL", :call
      :call
    else
      :not_option
    end
  end
end
