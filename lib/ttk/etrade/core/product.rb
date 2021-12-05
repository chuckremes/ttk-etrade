require 'forwardable'

class TTK::ETrade::Core::Product
  extend Forwardable
  def_delegators :@expiration,
                 :raw_year,
                 :raw_month,
                 :raw_day

  def initialize(hash)
    @body       = hash
    @expiration = Expiration.new(hash)
  end

  def security_type
    case raw_security_type
    when 'OPTN' then :equity_option
    when 'EQ' then :equity
    when 'INDX' then :equity
    else
      raise "Unknown Product type from #{@body.inspect}, revise list!"
    end
  end

  def raw_security_type
    @body['securityType']
  end

  def callput
    convert_callput(raw_callput) || :not_option
  end

  def raw_callput
    @body['callPut']
  end

  def strike
    @body['strikePrice'] || 0
  end

  def symbol
    @body['symbol']
  end

  def expiration_string
    @expiration.iso8601
  end

  def expiration_date
    @expiration.date
  end

  def osi
    if equity_option?
      symbol.ljust(6, '-') +
        (expiration_date.year % 2000).to_s.rjust(2, '0') +
        expiration_date.month.to_s.rjust(2, '0') +
        expiration_date.day.to_s.rjust(2, '0') +
        (call? ? 'C' : 'P') +
        strike.to_i.to_s.rjust(5, '0') + ((strike - strike.to_i) * 1000).to_i.to_s.rjust(3, '0')
    else
      symbol
    end
  end

  def inspect
    "#{self.class}: \n" +
      "                  symbol: #{symbol}\n" +
      "              expiration: #{expiration_string}\n" +
      "                 callput: #{callput}\n" +
      "                  strike: #{strike}\n"
  end

  def call?
    :call == callput
  end

  def put?
    :put == callput
  end

  def equity?
    :equity == security_type
  end

  def equity_option?
    :equity_option == security_type
  end

  def to_product
    h = {
      'symbol'       => symbol,
      'securityType' => raw_security_type
    }

    if raw_security_type == 'OPTN'
      h.merge(
        'callPut'     => raw_callput,
        'expiryYear'  => raw_year.to_s,
        'expiryMonth' => raw_month.to_s.rjust(2, '0'),
        'expiryDay'   => raw_day.to_s.rjust(2, '0'),
        'strikePrice' => strike.to_s
      )
    else
      h
    end
  end

  private

  def convert_callput(cp)
    case cp
    when 'PUT', :put
      :put
    when 'CALL', :call
      :call
    else
      nil
    end
  end

  class Expiration
    include Comparable

    def initialize(hash)
      @body = hash
    end

    def year
      raw_year || 2100
    end

    def raw_year
      @body['expiryYear']
    end

    def month
      raw_month || 1
    end

    def raw_month
      @body['expiryMonth']
    end

    def day
      raw_day || 1
    end

    def raw_day
      @body['expiryDay']
    end

    def date
      # If jsut an equity, put expiration into the distant future
      @date ||= Date.new(year, month, day)
    end

    def iso8601
      @iso8601 ||= ("%04d%02d%02d" % [year, month, day])
    end

    def <=>(other)
      date <=> other.date
    end
  end
end
