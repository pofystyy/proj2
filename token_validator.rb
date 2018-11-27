require 'jwt'

module TokenValidator

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
