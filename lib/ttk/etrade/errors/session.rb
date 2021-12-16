require "oj"

class TTK::ETrade::Errors::Session < StandardError
  def initialize(code:, message:, context:)
    super(reformat(code, message, context))
  end

  def reformat(code, message, context)
    Oj.dump(
      code: code,
      message: message,
      context: context
    )
  end
end
