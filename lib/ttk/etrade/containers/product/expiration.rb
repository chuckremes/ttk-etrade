class TTK::ETrade::Containers::Product
  class Expiration
    include Comparable

    def initialize(hash)
      @body = hash
    end

    def year
      raw_year || 2100
    end

    def raw_year
      @body["expiryYear"]
    end

    def month
      raw_month || 1
    end

    def raw_month
      @body["expiryMonth"]
    end

    def day
      raw_day || 1
    end

    def raw_day
      @body["expiryDay"]
    end

    def date
      # If just an equity, put expiration into the distant future
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
