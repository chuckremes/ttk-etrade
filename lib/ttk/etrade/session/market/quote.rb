# Wraps all calls to the ETrade REST API and converts
# the responses to Session::Result objects.
#
module TTK
  module ETrade
    module Session
      module Market
        class Quote < Session::Base
          MAX_SYMBOLS = 50
          MAX_BOUNDARY = 25
          URL = "/v1/market/quote/"

          def lookup(symbols, detail_flag:)
            slice_index = 0
            quotes = []

            elapsed("Quote lookup for #{symbols.size} symbols...") do
              Async do
                wait do
                  begin
                    subarray = symbols.slice(slice_index, MAX_SYMBOLS) || []
                    break if subarray.empty?
                    puts "fetching quotes from #{slice_index} to #{slice_index + subarray.size}"
                    override = subarray.size > MAX_BOUNDARY
                    params = {detailFlag: detail_flag,
                      skipMiniOptionsCheck: true,
                      overrideSymbolCount: override}

                    # get "em
                    symbol_path = URL + subarray.join(",")
                    async_limiter(text: "Getting quotes from index #{slice_index}") do
                      result = get(symbol_path, query_params: params)
                      error_check(result, context: {url: symbol_path,
                        detailFlag: detail_flag,
                        overrideSymbolCount: override,
                        skipMiniOptionsCheck: true,
                        query_params: params})

                      quotes.concat((result.value.dig("QuoteResponse", "QuoteData") || []))
                    end
                    # binding.pry
                    slice_index += subarray.size
                  end while true
                end
              end
            end

            # p "quotes size", quotes.size
            quotes
          end
        end
      end
    end
  end
end
