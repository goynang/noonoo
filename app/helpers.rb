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
        'content' => { 'primary' => [], 'secondary' => []}
      }
    end
    
    def render_page(page)
      content = parse_content(page)
      # TODO: make the template to load dynamic from the page object (rather than hardcoding this as :page)
      erb :page, locals: {page: page, content: content}
    end

    def parse_content(page)
      # TODO: Verify JSON object is well formed as a page (contains correct elements)
      content = {}
          
      page.layout.zones.each do |zone, components|
        (content[zone] ||= '') << render_components(components, page)
      end unless page.layout.nil? || page.layout.zones.empty?
      
      page.zones.each do |zone, components|
        (content[zone] ||= '') << render_components(components, page)
      end unless page.zones.nil? || page.zones.empty?
      
      OpenStruct.new(content)
    end
    
    # Render collection of components within a page and return string of combined results
    def render_components(components, page)
      rendered = ''
      components.each do |component|
        rendered << render_component(OpenStruct.new(component), page)
      end
      rendered
    end
    
    # Render individual component and return result as a string
    def render_component(component, page)
      erb(:view, {
        views: "components/#{component.name}",
        layout: :component,
        layout_options: { :views => 'views' },
        locals: {page: page, component: component}
      })
    end
  end
end