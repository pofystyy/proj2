require 'jwt'
require 'yaml'

class MyApp

  HMAC_SECRET  = "#{ENV["HMAC_SECRET"]}"

  # HTTP Status Codes
  UNAUTHORIZED = 401
  OK           = 200

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    response
  end

  private

  def response
    response = Rack::Response.new
    payload = decode

    if safe_path?
      response.status = OK
    elsif payload
      response['X-Auth-User'] = payload
      response.status = OK
    else
      response.status = UNAUTHORIZED
    end
    response.finish
  end

  def white_list
    YAML.load_file('white_list.yml')
  end

  def safe_path?
    host = @env["HTTP_HOST"].scan(/^\w+/).join
    path = @env["PATH_INFO"].scan(/\/\w+$/).join

    white_list[host].include?(path) if white_list.keys.include?(host)
  end

  def token_present?
    @env["HTTP_AUTHORIZATION"] =~ /^Bearer /
  end

  def token
    @env["HTTP_AUTHORIZATION"].gsub('Bearer ', '') if token_present?
  end

  def decode
    JWT.decode(token, HMAC_SECRET, true, { algorithm: 'HS256' }).first
  rescue JWT::DecodeError
    false
  end
end

