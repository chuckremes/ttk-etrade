
# Configuration file should have the following keys in the JSON
# format:
#
#   "consumer_key": string,
#   "consumer_secret": string,
#   "sandbox": boolean,
#   "redirect_url": string | nil,
#   "vendor": "etrade"
#
class TTK::ETrade::Config::Login < TTK::ETrade::Config

  def consumer_key
    contents[:secrets][:consumer_key]
  end

  def consumer_secret
    contents[:secrets][:consumer_secret]
  end

  def sandbox
    contents[:sandbox]
  end

  def redirect_url
    contents[:redirect_url]
  end

  def token_path
    contents[:token_path]
  end

  private

  def setup_structure
    @contents = {
      secrets: {
        consumer_secret: nil,
        consumer_key: nil,
      },
      sandbox: nil,
      redirect_url: nil,
      token_path: nil,
    }.merge(super)
  end

  def fill_structure(hash)
    contents[:secrets][:consumer_key] = hash.dig("login", "consumer_key")
    contents[:secrets][:consumer_secret] = hash.dig("login", "consumer_secret")
    contents[:sandbox] = hash.dig("login", "sandbox")
    contents[:redirect_url] = hash.dig("login", "redirect_url") || "oob"
    contents[:token_path] = hash.dig("login", "token_path")
  end

  def flatten(contents)
    {
      login: {
        consumer_key: contents[:secrets][:consumer_key],
        consumer_secret: contents[:secrets][:consumer_secret],
        sandbox: contents[:sandbox],
        redirect_url: contents[:redirect_url],
        token_path: contents[:token_path]
      }.merge(super)
    }
  end
end
