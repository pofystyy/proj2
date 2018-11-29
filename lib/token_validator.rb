require 'jwt'

class TokenValidator


  def self.secret
    "#{ENV["HMAC_SECRET"]}"
  end

  def self.decode(token)
    JWT.decode(token, secret, true, { algorithm: 'HS256' }).first
  rescue JWT::DecodeError
    false
  end
end
