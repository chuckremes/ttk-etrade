require_relative '../../../../../ttk-etrade-oauth/lib/ttk/etrade/oauth'
require 'launchy'

# 1. Try to load an existing token and use it.
# a. If expired, go through full process
# b. If not expired, use loaded session

class TTK::ETrade::Core::Login
  FailedAuthenticationBlock = Class.new(StandardError)

  def initialize(config)
    @config = config
  end

  def session
    @session ||= OAuth.make_session(@config)
  end

  class OAuth
    def self.make_session(config)
      session = load_session(config.token_path)

      if session.expired?
        session = build_session(config)
        authenticate!(session, config)
        persist(session, config.token_path)
      end

      session
    end

    def self.load_session(path)
      return TTK::ETrade::OAuth::NullSession unless File.exist?(path)

      session = Marshal.load(File.binread(path))
      session.renew
      session
    end

    def self.build_session(config)
      TTK::ETrade::OAuth::Session.new(
        consumer_key:    config.consumer_key,
        consumer_secret: config.consumer_secret,
        redirect_url:    config.redirect_url,
        sandbox:         config.sandbox)
    end

    def self.authenticate!(session, config)
      session.authenticate do |auth_url|
        Launchy.open(auth_url) # launch browser to authenticate and generate auth code

        print "Enter the code from the ETrade browser tab: "

        # last line of block must return the oauth_verifier code
        code = STDIN.gets&.chomp # read code from console
        puts "got code [#{code}]"
        code
      end

      # When this raises it's likely due to the above block generating an
      # error and not returning a valid code
      raise FailedAuthenticationBlock.new("Session auth failed! Check block outcome.") if session.expired?
    end

    def self.persist(session, token_path)
      File.open(token_path, 'wb') do |f|
        f.write(Marshal.dump(session))
      end
    end
  end
end
