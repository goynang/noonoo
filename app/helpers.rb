class App < Sinatra::Base
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
      }
    end

    # Convert the JSON content held within a page object into actual strings via relevant component templates.
    # Returned object contains content as strings for each zone that the page contains.
    def parse_content(page)
      content = {}
      page.content.each do |zone, components|
        components.each_with_index do |component, i|
          component = OpenStruct.new(component)
          (content[zone] ||= '') << erb(:view, {
            views: "components/#{component.name}",
            layout: :component,
            layout_options: { :views => 'views' },
            locals: {component: component, index: i}
          })
        end
      end
      OpenStruct.new(content)
    end
  end
end