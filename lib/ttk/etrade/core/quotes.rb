# Wraps all calls to the ETrade REST API and converts
# the responses to Session::Result objects.
#
class TTK::ETrade::Core::Quotes < TTK::ETrade::Core::Session
  MAX_SYMBOLS = 25
  URL         = "/v1/market/quote/"

  def initialize(config:, api_session:, parent: nil, body: {}, reload_now: true)
    super
  end

  def empty_quote(type)
    case type
    when :equity then TTK::ETrade::Core::Quote::Intraday.new
    when :equity_option then TTK::ETrade::Core::Quote::Options.new
    end
  end

  def equity_quote(symbols)
    quotes = quote(symbols, { detailFlag: "INTRADAY" })
    wrap(quotes: quotes, klass: TTK::ETrade::Core::Quote::Intraday)
  end

  def equity_option_quote(symbols)
    quotes = quote(symbols, { detailFlag: "OPTIONS" })
    wrap(quotes: quotes, klass: TTK::ETrade::Core::Quote::Options)
  end

  def quote(symbols, query)
    slice_index = 0
    quotes      = []

    begin
      subarray = symbols.slice(slice_index, MAX_SYMBOLS) || []
      break if subarray.empty?

      # get "em
      symbol_path = URL + subarray.join(",")
      result      = get(symbol_path, query_params: query)
      @body       = if result.success?
                      result.value
                    else
                      STDERR.puts "#{self.class}: reload failed, #{result.inspect}"
                      {}
                    end

      quotes.concat((@body.dig("QuoteResponse", "QuoteData") || []))
      # p @body
      # binding.pry
      slice_index += MAX_SYMBOLS
    end while true

    # p "quotes size", quotes.size
    quotes
  end

  def wrap(quotes:, klass:)
    quotes.map do |quote_data|
      klass.make(quote_data)
    end
  end

  def get(path, query_params: {})
    TTK::ETrade::Core::Session::Result.new(api_session.get(path, query_params: query_params))
  end

  private

  attr_reader :api_session, :config, :parent, :body
end
