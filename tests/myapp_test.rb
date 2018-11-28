require_relative '../main'
require_relative '../app'

require 'pry'
require 'test/unit'
require 'rack/test'
require 'jwt'

class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    MyApp.new(Main.new)
  end

  def setup
    @payload = { 'user' => 1 }
    @secret  = "#{ENV["HMAC_SECRET"]}"
    @algo    = 'HS256'

    @valid_token   = JWT.encode @payload, @secret, @algo
    @invalid_token = JWT.encode @payload, 'something else', @algo

    @default_url = 'https://resources.com/'
  end

  def test_the_path_in_white_list_response_is_200
    get 'https://auth.com/signup/name'

    assert_equal 200, last_response.status
  end

  def test_the_method_not_in_white_list_response_is_401
    post 'https://auth.com/signup/name'

    assert_equal 401, last_response.status
  end

  def test_the_path_in_white_list_v2_response_is_200
    get 'https://resources.com/countries/uk'

    assert_equal 200, last_response.status
  end

  def test_the_path_and_method_in_white_list_v2_response_is_200
    post 'https://resources.com/countries'

    assert_equal 200, last_response.status
  end

  def test_without_token_response_is_401
    get @default_url

    assert_equal 401, last_response.status
  end

  def test_availability_of_the_key_in_header
    header 'Authorization', "Bearer #{@valid_token}"
    get @default_url

    assert_equal true, last_response.header.include?('X-Auth-User')
  end

  def test_definition_of_the_key_correspondence_to_value
    header 'Authorization', "Bearer #{@valid_token}"
    get @default_url

    assert_equal @payload, last_response.header['X-Auth-User']
  end

  def test_token_with_the_correct_secret_key_response_is_200
    header 'Authorization', "Bearer #{@valid_token}"
    get @default_url

    assert_equal 200, last_response.status
  end

  def test_token_with_the_wrong_secret_key_response_is_401
    header 'Authorization', "Bearer #{@invalid_token}"
    get @default_url

    assert_equal 401, last_response.status
  end
end
