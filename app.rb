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

class App < Sinatra::Base
  configure :development do
      register Sinatra::Reloader
  end
  
  set :app_file, __FILE__
  set :views, settings.root + '/views'
  
  helpers do
    # Convert human friendly string into one suitable for use in a URL as a path part.
    def slugify(value)
      '/' + value.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end

    # Create a basic JSON object representing a page.
    # The title is used to create the path (used in URL).
    def build_page(title)
      {
        'path' => slugify(title),
        'title' => title,
        'content' => { 'primary' => [], 'secondary' => []}
      }.to_json
    end

    # Convert the JSON content held within a page object into actual strings via relevant component templates.
    # Returned object contains content as strings for each zone that the page contains.
    def parse_content(page)
      content = {}
      page.content.each do |zone, components|
        components.each_with_index do |component, i|
          component = OpenStruct.new(component)
          views  = "components/#{component.name}"
          layout_options = { :views => 'views' }
          locals = {component: component, index: i}
          (content[zone] ||= '') << erb(:view, {views: views, layout: :component, layout_options: layout_options, locals: locals})
        end
      end
      OpenStruct.new(content)
    end
  end
end

# Models

class Page
  include Mongoid::Document
  
  belongs_to :layout
    
  field :title, :type => String
  field :path,  :type => String
  field :content, :type => Object
end

class Layout
  include Mongoid::Document
  
  has_many :pages
  has_and_belongs_to_many :zones
  
  field :title, :type => String
end

class Zone
  include Mongoid::Document
  
  has_and_belongs_to_many :layouts
  
  field :title, :type => String
end

class Placement
  include Mongoid::Document
  
  has_and_belongs_to_many :zones
  has_and_belongs_to_many :components
end

class Component
  include Mongoid::Document
  
  has_and_belongs_to_many :placements

  field :name, :type => String
end