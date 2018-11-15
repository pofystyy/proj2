require_relative '../main'
require_relative '../app'

require "test/unit"
require "rack/test"

class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    MyApp.new(Main.new)
  end

  def test_response_is_401
    get '/'
    assert last_response.status == 401
  end

  def test_response_is_200
    header  "Authorization", "Bearer "
    get '/'
    assert last_response.status == 200
  end
end

