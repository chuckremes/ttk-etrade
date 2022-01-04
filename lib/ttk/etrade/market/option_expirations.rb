module TTK
  module ETrade
    module Market
      class OptionExpirations
        include Enumerable

        def initialize
          @body = {}
        end

        def update(from_array:)
          @body = from_array
          self
        end

        def each(&blk)
          body.each {|element| yield(Expiration.new(element)) }
        end

        class Expiration
          include Comparable

          def initialize(body)
            @body = body
          end

          def <=>(other)
            date <=> other.date
          end

          def year
            body.dig("year")
          end

          def month
            body.dig("month")
          end

          def day
            body.dig("day")
          end

          def type
            # WEEKLY, MONTHEND, MONTHLY, QUARTERLY
            body.dig("expiryType").downcase.to_sym
          end

          def date
            Date.new(year, month, day)
          end

          def dte
            (date - Date.today).to_i
          end

          private attr_reader :body
        end

        private attr_reader :body
      end
    end
  end
end
