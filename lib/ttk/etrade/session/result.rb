require "oj"

# Wraps all calls to the ETrade REST API and converts
# the responses to Session::Result objects.
#
class TTK::ETrade::Session::Result
  ParseError = Class.new(StandardError)

  attr_reader :code, :body

  def initialize(response)
    @error    = false
    @response = response
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

  def headers(io = STDERR)
    @response.each_header do |header, values|
      io.puts "\t#{header}: #{values.inspect}"
    end
  end

  private

  def parse(response)
    @code = response.code.to_s
    @body = Oj.load(response.body) unless no_content?
  rescue => e
    parse_error(e, response)
  end

  def parse_error(exception, response)
    STDERR.puts "parse_error, msg [#{exception.message}], http status [#{code}]"

      @error     = true
      @exception = ParseError.new("Exception: #{exception.message}, response: #{response.inspect}")
      raise @exception
  end

  def no_content?
    code.to_i == 204
  end
end
