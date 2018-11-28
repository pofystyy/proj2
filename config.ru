require './lib/main'
require './lib/app'

use Rack::Reloader
use MyApp
run Main.new
