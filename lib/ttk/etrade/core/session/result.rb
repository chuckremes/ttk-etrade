require "oj"

# Wraps all calls to the ETrade REST API and converts
# the responses to Session::Result objects.
#
class TTK::ETrade::Core::Session::Result
  ParseError = Class.new(StandardError)

  def initialize(response)
    @error = false
    parse(response)
  end

  def success?
    !failure? # !@error && @code =~ /2??/
  end

  def failure?
    @error || @code !~ /2??/
  end

  def value
    @body || {}
  end


  private

  def parse(response)
    @body = Oj.load(response.body)
    @code = response.code.to_s
  rescue => e
    parse_errorw(e, response)
  end

  def parse_error(exception, response)
    STDERR.puts "parse_error, msg [#{exception.message}]"
    @error = true
    @exception = ParseError.new("Exception: #{exception.message}, response: #{response.inspect}")
  end
end
