require 'jwt'

class MyApp

  HMAC_SECRET = "#{ENV["HMAC_SECRET"]}"

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    status, header, body = @app.call(env)
    [new_status, header, body ]
  end

  private

  def token_present?
    @env["HTTP_AUTHORIZATION"] =~ /^Bearer /
  end

  def token
    @env["HTTP_AUTHORIZATION"].gsub('Bearer ', '') if token_present?
  end

  def decode
    JWT.decode(token, HMAC_SECRET, true, { algorithm: 'HS256' })
  rescue JWT::DecodeError
      false
  end

  def new_status
    decode ? 200 : 401
  end
end

