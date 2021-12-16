require "forwardable"
require_relative "expiration"

# for ComposedMethods
# temporary until ttk-containers is made into a real gem
require_relative "../../../../../../ttk-containers/lib/ttk/containers/product/shared"


class TTK::ETrade::Containers::Product
  include TTK::Containers::Product::ComposedMethods

  extend Forwardable
  def_delegators :@expiration,
                 :raw_year,
                 :raw_month,
                 :raw_day

  NullExpiration = Struct.new(:year, :month, :day).new(0, 0, 0)

  def initialize(hash)
    @body       = hash
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
    return @body["strikePrice"] if equity_option?
    0
  end

  def symbol
    @body["symbol"]
  end

  def expiration_string
    @expiration.iso8601
  end

  def expiration_date
    return @expiration.date if equity_option?
    NullExpiration
  end

  def inspect
    "#{self.class}: \n" +
      "                  symbol: #{symbol}\n" +
      "              expiration: #{expiration_string}\n" +
      "                 callput: #{callput}\n" +
      "                  strike: #{strike}\n"
  end

  def to_product
    h = {
      "symbol"       => symbol,
      "securityType" => raw_security_type
    }

    if equity_option?
      h.merge(
        "callPut"     => callput.to_s.upcase,
        "expiryYear"  => raw_year.to_s,
        "expiryMonth" => raw_month.to_s.rjust(2, "0"),
        "expiryDay"   => raw_day.to_s.rjust(2, "0"),
        "strikePrice" => strike.to_s
      )
    else
      h
    end
  end

  private

  def convert_callput(cp)
    case cp
    when "PUT", :put
      :put
    when "CALL", :call
      :call
    else
      nil
    end
  end
end
