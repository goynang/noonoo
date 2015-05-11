require 'sinatra/base'
require 'json'

module NooNoo
  class App < Sinatra::Application

    set :session_secret, '8uhsgfr567yujsh'

    # Home page
    # TODO: Make this check if homepage exists (create default one if not) - then call get '/home'
    get '/' do
      'Nothing to see here!'
    end

    # Handle upload of a binary file (e.g. an image)
    # Simply store the file in a sensible location and return the location for storing in Mongo (etc.)
    # TODO: Make this more flexible (currently hard coded to only support image paths)
    post "/upload" do
      files = []
      for file in params['files'] do
        File.open('public/uploads/images/' + file[:filename], "w") do |f|
          f.write(file[:tempfile].read)
        end
        files << { url: "/uploads/images/#{file[:filename]}" }
      end
      JSON.generate({ files: files })
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
      page = Page.find_by(path: params[:splat].join('/').to_s)
      page.update_attributes(JSON.parse(params['page']))
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

  end
end