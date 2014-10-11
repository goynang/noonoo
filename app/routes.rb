require 'sinatra/base'
require 'json'

module NooNoo
  class App < Sinatra::Application

    set :session_secret, '8uhsgfr567yujsh'

    # Home page
    # TODO: What should this show/do?
    get '/' do
      'Nothing to see here!'
    end

    # Handle upload of a binary file (e.g. an image)
    # Simply store the file in a sensible location and return the location for storing in Mongo (etc.)
    # TODO: Make this more flexible (currently hard coded to only support image paths)
    post "/upload" do 
      File.open('public/uploads/images/' + params['file'][:filename], "w") do |f|
        f.write(params['file'][:tempfile].read)
      end
      "/uploads/images/#{params['file'][:filename]}"
    end

    # Handle creating a new page
    # Params passed in should represent the page to create
    # TODO: Maybe change this to simply / (although that clashes with below)
    post "/new" do
      page = Page.new(build_page(params[:title]))
      page.layout = Layout.first # TODO: let the user select the layout they want!
      page.save
      redirect page.path
    end

    # Handle changes to a page (path identifies page)
    # TODO: Maybe change this to 'patch' as that better matches with HTTP goals
    post "*" do
      content_type :json
      page = Page.find_by(path: params[:splat].join('/').to_s)
      page.update_attributes(JSON.parse(params['page']))
      page.to_json
    end

    # Handle display of a page
    get '*' do
      page = Page.find_by(path: params[:splat].join('/').to_s)
      if params[:component]
        component = Component.new({name: params[:component]}) # TODO: replace with clever defaults from component
        render_component(component, page)
      else
        render_page(page)
      end
    end

  end
end