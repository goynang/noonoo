require 'mongoid'

module NooNoo
  module Models
    class Page
      include Mongoid::Document
      
      store_in collection: "pages"
  
      belongs_to :layout
    
      field :title, :type => String
      field :path,  :type => String
      field :content, :type => Object
    end

    class Layout
      include Mongoid::Document
      
      store_in collection: "layouts"
  
      has_many :pages
      has_and_belongs_to_many :zones
  
      field :title, :type => String
    end

    class Zone
      include Mongoid::Document
      
      store_in collection: "zones"
  
      has_and_belongs_to_many :layouts
  
      field :title, :type => String
    end

    class Placement
      include Mongoid::Document
      
      store_in collection: "placements"
  
      has_and_belongs_to_many :zones
      has_and_belongs_to_many :components
    end

    class Component
      include Mongoid::Document
      
      store_in collection: "components"
  
      has_and_belongs_to_many :placements

      field :name, :type => String
    end
  end
end