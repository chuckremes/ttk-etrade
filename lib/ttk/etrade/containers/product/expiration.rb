class TTK::ETrade::Containers::Product
  class Expiration
    include Comparable

    def self.null
      new(
        {
          "expiryYear" => 1970,
          "expiryMonth" => 1,
          "expiryDay" => 1
        }
      )
    end

    def initialize(hash)
      @body = hash
    end

    def year
      return 1970 if raw_year.to_i <= 0
      raw_year
    end

    def raw_year
      @body["expiryYear"]
    end

    def month
      return raw_month.to_i if raw_month.to_i.between?(1, 12)
      1
    end

    def raw_month
      @body["expiryMonth"]
    end

    def day
      return raw_day.to_i if raw_day.to_i.between?(1, 31)
      1
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
