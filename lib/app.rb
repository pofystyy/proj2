require_relative '../config/config'
require_relative 'token_validator'
require_relative 'white_list_validator'

class MyApp

  # HTTP Status Codes
  OK           = 200
  UNAUTHORIZED = 401

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    response
  end

  private

  def response
    response             = Rack::Response.new
    token_validator      = TokenValidator.new(@env)
    white_list_validator = WhiteListValidator.new(@env)

    payload = token_validator.decode

    if white_list_validator.host_in_white_list?
      if white_list_validator.host_valid?
        response.status = OK
      elsif payload
        response['X-Auth-User'] = payload
        response.status = OK
      else
        response.status = UNAUTHORIZED
      end
    else
      response.status = UNAUTHORIZED
    end
    response.finish
  end
end
