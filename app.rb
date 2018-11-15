class MyApp

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    status, @header, body = @app.call(env)
    [new_status, @header, body ]
  end

  private

  def token_present?
    @env["HTTP_AUTHORIZATION"] =~ /^Bearer /
  end

  def new_status
    token_present? ? 200 : 401
  end
end

