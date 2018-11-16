require 'jwt'

class MyApp

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    status, header, body = @app.call(env)
    [new_status, header, body ]
  end

  private

  def token
    @env["HTTP_AUTHORIZATION"].gsub('Bearer ', '')
  end

  def decode
    begin
      JWT.decode(token, 'my$ecretK3y', true, { algorithm: 'HS256' })
    rescue
    end
  end

  def new_status
    decode ? 200 : 401
  end
end

