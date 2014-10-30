require 'mongoid'

module NooNoo
  module Models
    class Page
      include Mongoid::Document
      
      store_in collection: "pages"
  
      belongs_to :layout
    
      field :title, :type => String
      field :path,  :type => String
      field :depth, :type => Integer
      field :zones, :type => Hash
      
      accepts_nested_attributes_for :layout
      
      before_create do |page|
        self.count = self.path.split('/').size - 1
      end
    end

    class Layout
      include Mongoid::Document
      
      store_in collection: "layouts"
  
      has_many :pages
  
      field :title, :type => String
      field :zones, :type => Array
    end

    class Component
      include Mongoid::Document
      
      store_in collection: "components"
        
      field :name, :type => String
      field :klass, :type => String
      # All other fields are specific to type of component (no predetermined schema)
    end
  end
end