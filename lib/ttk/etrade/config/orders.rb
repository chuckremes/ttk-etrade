class TTK::ETrade::Config::Orders < TTK::ETrade::Config

  def allowed_underlying
    contents[:allowed_underlying]
  end

  def start_date
    # ETrade API requires this order of values
    contents[:start_date].strftime("%m%d%Y")
  end

  def end_date
    # ETrade API requires this order of values
    contents[:end_date].strftime("%m%d%Y")
  end

  private

  def setup_structure
    @contents = {
      allowed_underlying: nil,
      start_date:         nil,
      end_date:           nil,
    }.merge(super)
  end

  def fill_structure(hash)
    contents[:allowed_underlying] = hash.dig('orders', 'allowed_underlying') || []
    contents[:start_date]         = convert_date(hash.dig('orders', 'start_date')) rescue Date.today
    contents[:end_date]           = convert_date(hash.dig('orders', 'end_date')) rescue Date.today
  end

  def flatten(contents)
    {
      orders: {
                   allowed_underlying: contents[:allowed_underlying],
                   start_date:         contents[:start_date].strftime("%Y%m%d"),
                   end_date:           contents[:end_date].strftime("%Y%m%d"),
                 }.merge(super)
    }
  end

  def convert_date(string)
    Date.strptime(string, '%Y%m%d')
  end
end


