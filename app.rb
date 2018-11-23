require 'jwt'
require 'yaml'

class MyApp

  HMAC_SECRET = "#{ENV["HMAC_SECRET"]}"

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    response
  end

  private

  def response
    @resp = Rack::Response.new

    if safe_path?
      @resp.status = 200
    elsif decode
      @resp['X-Auth-User'] = decode.first
      @resp.status = 200
    else
      @resp.status = 401
    end
    @resp.finish
  end

  def white_list
    YAML.load_file('white_list.yml')
  end

  def safe_path?
    host = @env["HTTP_HOST"].scan(/^\w+/).join
    path = @env["PATH_INFO"].scan(/\/\w+$/).join

    white_list.assoc(host)[1].include?(path) if white_list.keys.include?(host)
  end

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
end

