require 'jwt'

class TokenValidator

  def initialize(env)
    @env = env
  end

  def secret
    "#{ENV["HMAC_SECRET"]}"
  end

  def token_present?
    @env["HTTP_AUTHORIZATION"] =~ /^Bearer /
  end

  def token
    @env["HTTP_AUTHORIZATION"].gsub('Bearer ', '') if token_present?
  end

  def decode
    JWT.decode(token, secret, true, { algorithm: 'HS256' }).first
  rescue JWT::DecodeError
    false
  end
end
