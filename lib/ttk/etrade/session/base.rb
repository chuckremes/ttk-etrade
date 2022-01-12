
# Wraps all calls to the ETrade REST API and converts
# the responses to Session::Result objects.
#
class TTK::ETrade::Session::Base
  def initialize(api_session:, limiter: nil, barrier: nil)
    @api_session = api_session
    @limiter = limiter
    @barrier = nil
    @cache = []
  end

  def get(path, query_params: {})
    TTK::ETrade::Session::Result.new(api_session.get(path, query_params: query_params))
  end

  def post(path, payload)
    TTK::ETrade::Session::Result.new(api_session.post(path, body: payload))
  end

  def put(path, payload)
    TTK::ETrade::Session::Result.new(api_session.put(path, body: payload))
  end

  def error_check(result, context:)
    return if result.success?

    code = result.value.split("<code>")[1].split("</code>").first.to_i
    message = result.value.split("<message>")[1].split("</message>").first
    raise TTK::ETrade::Errors::Errors[code].new(code: code, message: message, context: context)
  end

  def async_limiter(text:)
    STDERR.puts text
    return yield unless @limiter

    @limiter.async do
      yield
    end
  end

  def wait
    yield
    @barrier&.wait
  end

  private

  attr_reader :api_session


  def elapsed(d)
    start = Time.now
    yield
    e = Time.now
    elap = (e - start).round(1)
    puts "#{d} took [#{elap}] seconds to run"
  end
end
