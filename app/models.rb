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