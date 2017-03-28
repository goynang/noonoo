require 'ostruct'

module NooNoo
  module Helpers
  
    # Convert human friendly string into one suitable for use in a URL as a path part.
    def slugify(value)
      '/' + value.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end

    # Create a basic JSON object representing a page.
    # The title is used to create the path (used in URL).
    def build_page(title)
      # TODO: Do we need to state the layout/template here?
      {
        'path' => slugify(title),
        'title' => title,
        'zones' => { 'primary' => [], 'secondary' => []}
      }
    end
    
    def render_page(page, params)
      content = parse_content(page, params)
      # TODO: make the template to load dynamic from the page object (rather than hardcoding this as :page)
      
      if request.xhr?
       erb :page, layout: false, locals: {page: page, content: content}
      else 
         erb :page, locals: {page: page, content: content} 
      end
    end

    def parse_content(page, request)
      # TODO: Verify JSON object is well formed as a page (contains correct elements)
      content = {}
          
      page.layout.zones.each do |zone, components|
        (content[zone] ||= '') << render_components(components, page, request)
      end unless page.layout.nil? || page.layout.zones.empty?
      
      page.zones.each do |zone, components|
        (content[zone] ||= '') << render_components(components, page, request)
      end unless page.zones.nil? || page.zones.empty?
      
      OpenStruct.new(content)
    end
    
    # Render collection of components within a page and return string of combined results
    def render_components(components, page, request)
      rendered = ''
      components.each do |component|
        rendered << render_component(OpenStruct.new(component), page, request)
      end
      rendered
    end
    
    # Render individual component and return result as a string
    def render_component(component, page, request)
      locals = {page: page, component: component}
      
      filename = "components/#{component.name}/#{component.name}.rb"
      if File.file?(filename)
        require_relative '../' + filename
        renderer = Object.const_get("NooNoo::Components::#{component.name.capitalize}")
        # if renderer.responds_to? :render
          locals = renderer.render(component, page, request)
        # else
        #  raise "Attempt to render component object that doesn't implement render method: #{component.name}"
        # end    
      end
      
      erb(:view, {
        views: "components/#{component.name}",
        layout: :component,
        layout_options: { :views => 'views' },
        locals: locals
      })
    end
  end
end