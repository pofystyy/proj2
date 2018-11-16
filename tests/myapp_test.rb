require_relative '../main'
require_relative '../app'

require "test/unit"
require "rack/test"

class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    MyApp.new(Main.new)
  end

  def test_without_token
    get '/'

    assert last_response.status == 401
  end

  def test_token_with_the_wrong_secret_key
    header  "Authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.rnOIgq7Ns429jktYhR5anXhGHUBVdElXC5WB2u75jss"
    get '/'

    assert last_response.status == 401
  end

  def test_token_with_the_correct_secret_key
    header  "Authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.KsCJ93f7pOyW1CaMCUqtFzVpiX7SaoaOIBqikbe9n_w"
    get '/'

    assert last_response.status == 200
  end
end

