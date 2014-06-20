$:.unshift File.join(__FILE__, "../config")
$:.unshift File.join(__FILE__, "../app")

require 'sinatra/base'
require 'sinatra/reloader'
require 'json'
require 'ostruct'
require 'mongoid'
require 'bundler/setup'
require 'app_config'
require 'routes'
require 'helpers'
require 'models'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end
  
  set :app_file, __FILE__
  set :views, settings.root + '/views'
end
