require './main'
require './app'

use Rack::Reloader
use MyApp
run Main.new
