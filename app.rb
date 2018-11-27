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

    if valid_data?
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

  def valid_data?
    arr = comparative_keys.map do |meth|
      (allowable_values[meth] & (meth == 'target' ? host_data[0][meth].split : host_data[0][meth]))
    end.delete_if {|el| el.empty? }

    arr.size == comparative_keys.size
  end

  def host_data
    host = @env["HTTP_HOST"]

    white_list[host] if white_list.keys.include?(host)
  end

  def allowable_values
    path = @env["PATH_INFO"].split("/")
    meth = @env["REQUEST_METHOD"].split

    { 'target' => path,
      'method' => meth
     }
  end

  def comparative_keys
    host_data[0].keys & allowable_values.keys
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

