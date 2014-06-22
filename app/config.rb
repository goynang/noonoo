require 'sinatra/base'
require 'sinatra/reloader'
require 'bundler/setup'
require 'mongoid'

module NooNoo
  class App < Sinatra::Application
    
    configure :development do
        Bundler.setup(:default, :assets, :development)
        register Sinatra::Reloader
        set :environment, :development
        enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run
        Mongoid.load!(File.expand_path(File.join("config", "mongoid.yml")))
    end
    
    configure :test do
      Bundler.setup(:default, :test)
      set :environment, :test
      enable :sessions, :static, :inline_templates, :method_override, :raise_errors
      disable :run, :dump_errors, :logging
      Mongoid.load!(File.expand_path(File.join("config", "mongoid.yml")))
    end
    
    configure :production do
      Bundler.setup(:default, :production)
      set :environment, :production
      enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run
      Mongoid.load!(File.expand_path(File.join("config", "mongoid.yml")))
    end

  end
end