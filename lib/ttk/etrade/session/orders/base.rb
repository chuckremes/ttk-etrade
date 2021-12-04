# Base class for all Order related API calls. Two reasons why
# we need a new base class. One, the Order APIs reuse the error
# codes so we need the shared error checking to reference
# the correct error list. Second, we need to rate limit access
# to these API calls and there may be benefits to accessing them
# all via a shared base class.
#
# Thin presentation around native format.
#
class TTK::ETrade::Session::Orders::Base < TTK::ETrade::Session::Base

  # def get(url, query_params)
    # Async do
    #   @limiter.async do |task|
    #
    #   end
    # end
  # end

  # def post(url, body)
    # Async do
    #   @limiter.async do |task|
    #
    #   end
    # end
  # end

  # def put(url, body)
    # Async do
    #   @limiter.async do |task|
    #
    #   end
    # end
  # end

  private


  def error_check(result, context:)
    # STDERR.puts "#{self.class}: error_check, failure? #{result.failure?} class #{result.value.class}, #{result.value}"

    if result.value.is_a?(Hash)
      return unless result.value.key?('Error')

      code = result.value.dig('Error', 'code')
      message = result.value.dig('Error', 'message')
    else
      code = result.value.split('<code>')[1].split('</code>').first.to_i
      message = result.value.split('<message>')[1].split('</message>').first
    end

    # check warnings first but default to errors if no warning found
    if TTK::ETrade::Errors::ORDER_WARNINGS.key?(code)
      raise TTK::ETrade::Errors::ORDER_WARNINGS[code].new(code: code, message: message, context: context)
    else
      raise TTK::ETrade::Errors::ORDER_ERRORS[code].new(code: code, message: message, context: context)
    end

  end

  # Prints debug info
  def debug(url, result)
    STDERR.puts '====== RESULT DEBUG URL ======='
    STDERR.puts url
    STDERR.puts '====== RESULT DEBUG STATUS ======='
    STDERR.puts "response code = #{result.code}"
    STDERR.puts '====== RESULT DEBUG HEADERS ======='
    result.headers(STDERR)
    STDERR.puts '====== RESULT DEBUG BODY ======='
    STDERR.puts result.body
    STDERR.puts '====== RESULT DEBUG END ======='
  end

end

