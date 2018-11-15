class MyApp

  def initialize(app)
    @app = app
  end

  def call(env)
    status, @header, body = @app.call(env)
    [new_status, @header, body]
  end

  private

  def token_present?
    @header.keys.include?("Authorization")
  end

  def new_status
    token_present? ? 200 : 401
  end
end

