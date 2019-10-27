require 'sinatra/base'
require 'json'

module NooNoo
  class App < Sinatra::Application

    set :session_secret, 'notasecret'
    
    # pubSubClient = Faye::Client.new("http://0.0.0.0:5000/pubsub")

    # Derermine correct site to load
    # Load it in so available elsewhere
    before do
      @site = Site.find_by(domains: request.host)
      halt 404 unless @site
    end
    
    # TODO: authorisation!
    
    patch "/@/site" do
      # TODO: update current site record with params
      redirect params[:return] || '/' # TODO: ensure on same domain etc.
    end
    
    get '/@/inspect/:component' do
      component = params[:component]
      filename = "components/#{component}/#{component}.rb"
      if File.file?(filename)
        require_relative '../' + filename
        component_class = Object.const_get("NooNoo::Components::#{component.capitalize}")
        erb(:inspect, {
          layout: nil,
          locals: {props: component_class.props}
        })
      end
    end

    # Handle creating a new page
    # Params passed in should represent the page to create (title, layout)
    # Upon success get redirected to freshly created page
    # TODO: Add auth
    post "/" do
      page = Page.new(build_page(params[:title]))
      page.layout = Layout.first # TODO: let the user select the layout they want!
      page.save
      redirect page.path
    end
    
    # Handle display of a page or component within context of a page
    # Presence (or otherwise) of component param determines which
    # Path determines page to load (either to render or give context to component)
    get '*' do
      page = Page.find_by(path: params[:splat].join('/').to_s)
      halt 404 unless page
      if params[:component]
        # TODO: replace dynamically loadad component object of relevant class???!?
        # TODO: replace with render method within the component implementation class
        component = Component.new({name: params[:component]}) 
        render_component(component, page, params)
      else
        render_page(page, params)
      end
    end

    # Handle changes to a page (path identifies page)
    # Returns JSON representation of the page
    # TODO: Add auth
    patch "*" do
      content_type :json
      path = params[:splat].join('/').to_s
      page = Page.find_by(path: path)
      halt 404 unless page
      
      # TODO: determine HTML diff here and only publish that back to the browser ???
      # TODO: Deal with stuff outside of viewport (like body style for columns)
      
      page.update_attributes(JSON.parse(params['page']))
        
      # Publish here or via cms.js save code????
      # pubSubClient.publish('/changes' + path, render_page(page, params))
      
      page.to_json
    end

    # Handle deletion of pages
    # Path indicates page to delete
    # If succesful get redirected to homepage
    # TODO: Add auth
    # TODO: Don't allow homepage to be deleted
    delete '*' do
      page = Page.find_by(path: params[:splat].join('/').to_s)
      page.destroy
      redirect '/?deleted=true'
    end
    
    not_found do
      'Page not found (TODO: make this prettier or even CMS editable!)'
    end

  end
end
