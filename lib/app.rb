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
    @response             = Rack::Response.new
    @white_list_validator = WhiteListValidator.new host:        @env['HTTP_HOST'],
                                                   path:        @env["PATH_INFO"].split('/'),
                                                   http_method: @env["REQUEST_METHOD"]

    response
  end

  private

  def token
    @env["HTTP_AUTHORIZATION"]&.gsub('Bearer ', '')
  end

   def white_list_resp
      payload = TokenValidator.decode(token)
      @response.status = OK if @white_list_validator.host_valid? || payload
      @response['X-Auth-User'] = payload
   end

  def response
    @response.status = UNAUTHORIZED

    white_list_resp if @white_list_validator.host_in_white_list?

    @response.finish
  end
end
