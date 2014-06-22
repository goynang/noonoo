require 'sinatra/base'
require 'json'

module NooNoo
  class App < Sinatra::Application

    get '/' do
      'Nothing to see here!'
    end

    get '/components/:component' do
      component = Component.new({name: params[:component]}) # replace with clever defaults from component
      views  = "components/#{params[:component]}"
      locals = {component: component, index: 1}
      erb(:view, {views: views, layout: :component, layout_options: { :views => 'views' }, locals: locals})
    end

    post "/upload" do 
      File.open('public/uploads/images/' + params['file'][:filename], "w") do |f|
        f.write(params['file'][:tempfile].read)
      end
      "/uploads/images/#{params['file'][:filename]}"
    end

    post "/new" do
      page = Page.new(build_page(params[:title]))
      page.save
      redirect page.path
    end

    post "*" do
      content_type :json
      page = Page.find_by(path: params[:splat].join('/').to_s)
      page.update_attributes(JSON.parse(params['page']))
      page.to_json
    end

    get '*' do
      page = Page.find_by(path: params[:splat].join('/').to_s)
      content = parse_content(page)
      # TODO: make the template to load dynamic from the page object
      erb :page, locals: {page: page, content: content} 
    end

  end
end