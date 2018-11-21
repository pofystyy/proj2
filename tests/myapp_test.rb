require_relative '../main'
require_relative '../app'

require 'test/unit'
require 'rack/test'
require 'jwt'

class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    MyApp.new(Main.new)
  end

  def setup
    @payload = { "user": 1 }
    @algo    = 'HS256'
    @secret  = "#{ENV["HMAC_SECRET"]}"
  end

  def test_the_path_in_white_list_response_is_200
    get '/signup'

    assert_equal 200, last_response.status
  end

  def test_the_path_in_white_list_v2_response_is_200
    get '/countries'

    assert_equal 200, last_response.status
  end

    def test_the_path_is_not_white_list_response_is_401
    get '/something_else'

    assert_equal 401, last_response.status
  end

  def test_without_token_response_is_401
    get '/'

    assert_equal 401, last_response.status
  end

  def test_token_with_the_wrong_secret_key_response_is_401
    token = JWT.encode @payload, 'something else', @algo
    header  'Authorization', "Bearer #{token}"
    get '/'

    assert_equal 401, last_response.status
  end

  def test_token_with_the_correct_secret_key_response_is_200
    token = JWT.encode @payload, @secret, @algo
    header  'Authorization', "Bearer #{token}"
    get '/'

    assert_equal 200, last_response.status
  end
end
