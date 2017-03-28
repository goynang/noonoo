require 'mongoid'
require 'mongoid/history'

Mongoid.raise_not_found_error = false

module NooNoo
  module Models
    class HistoryTracker
      include Mongoid::History::Tracker
    end
    
    class Page
      include Mongoid::Document
      include Mongoid::Timestamps
      include Mongoid::History::Trackable
            
      store_in collection: "pages"
  
      belongs_to :layout
    
      field :title, type: String
      field :label, type: String, default: -> { self.title }
      field :path,  type: String
      field :depth, type: Integer
      field :zones, type: Hash
      field :columns, type: Integer, default: 2
      
      field :publication_date, type: DateTime, default: ->{ Time.now }
      field :expiration_date, type: DateTime
      
      field :show_in_menus, type: Boolean, default: true
      field :show_on_sitemap, type: Boolean, default: true
      field :meta_robots, type: String
      
      accepts_nested_attributes_for :layout
      
      track_history on: [:fields, :embedded_relations] 
      
      before_create do |page|
        self.depth = self.path.split('/').size - 1 unless self.depth
      end
      
      def path_parts
        self.path.split('/')
      end
    end

    class Layout
      include Mongoid::Document
      include Mongoid::Timestamps
      
      
      store_in collection: "layouts"
  
      has_many :pages
  
      field :title, :type => String
      field :zones, :type => Hash
    end

    class Component
      include Mongoid::Document
      include Mongoid::Timestamps
      
      store_in collection: "components"
        
      field :name, :type => String
      field :klass, :type => String
      # All other fields are specific to type of component (no predetermined schema)
    end
  end
end