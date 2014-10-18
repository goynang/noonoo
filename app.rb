require 'sinatra/base'

require_relative 'app/config'
require_relative 'app/helpers'
require_relative 'app/models'
require_relative 'app/routes'

module NooNoo
  class App < Sinatra::Application
  
    set :app_file, __FILE__
    
    helpers NooNoo::Helpers

  end
end

# Make irb more useful ($irb and then $require './app.rb')
include NooNoo::Models