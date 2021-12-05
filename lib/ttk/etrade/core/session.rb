
# Wraps all calls to the ETrade REST API and converts
# the responses to Session::Result objects.
#
class TTK::ETrade::Core::Session
  def initialize(config:, api_session:, parent: nil, body: {}, reload_now: true)
    @config  = config
    @api_session = api_session
    @parent = parent
    @body = body
    @cache = []
    reload(api_session) if reload_now
  end

  def reload(session_ref = api_session)
    self
  end

  def get(path, query_params: {})
    TTK::ETrade::Core::Session::Result.new(api_session.get(path, query_params: query_params))
  end

  def post(path, payload)
    TTK::ETrade::Core::Session::Result.new(api_session.post(path, body: payload))
  end

  def put(path, payload)
    TTK::ETrade::Core::Session::Result.new(api_session.put(path, body: payload))
  end

  def error_check(result, context:)
    return if result.success?

    code = result.value.split('<code>')[1].split('</code>').first.to_i
    message = result.value.split('<message>')[1].split('</message>').first
    raise TTK::ETrade::Errors::Errors[code].new(code: code, message: message, context: context)
  end

  private

  attr_reader :api_session, :config, :parent, :body
end
