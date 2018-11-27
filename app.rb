require_relative 'config'
require_relative 'token_validator'
require_relative 'white_list_validator'

class MyApp

  include Config
  include TokenValidator
  include WhiteListValidator

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
end
