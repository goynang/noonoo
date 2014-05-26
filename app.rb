require 'sinatra'
require 'sinatra/reloader'
require 'rest_client'
require 'json'
require 'ostruct'

DB_URL = ENV['CLOUDANT_URL'] ? "#{ENV['CLOUDANT_URL']}/noonoo" : 'http://localhost:5984/testy'

get '/' do
  "Hello World!"
end

get '/components/:component' do
  component = OpenStruct.new({name: params[:component]}) # replace with clever defaults from component
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

post "/save" do
  page = JSON.parse(params['page'])
  content_type :json
  RestClient.put("#{DB_URL}/#{page['_id']}", params['page'], {:content_type => :json})
end

post "/new" do
  page = build_page(params[:title])
  id = slugify(params[:title])
  RestClient.put("#{DB_URL}/#{id}", page, {:content_type => :json})
  redirect "/#{id}"
end

get '/*' do
  page = get_page(params[:splat].join('/').to_s)
  content = get_content(page)
  # TODO: make the template to load dynamic from the page object
  erb :page, locals: {page: page, content: content} 
end



def build_page(title)
  {
    '_id' => slugify(title),
    'title' => title,
    'content' => { 'primary' => [], 'secondary' => []}
  }.to_json
end

def get_page(id)
  begin
    OpenStruct.new(JSON.parse(RestClient.get("#{DB_URL}/#{id}")))
  rescue
    OpenStruct.new({title: "Page not found" })
  end
end

def get_content(page)
  content = {}
  page.content.each do |zone, components|
    components.each_with_index do |component, i|
      component = OpenStruct.new(component)
      views  = "components/#{component.name}"
      layout_options = { :views => 'views' }
      locals = {component: component, index: i}
      (content[zone] ||= '') << erb(:view, {views: views, layout: :component, layout_options: layout_options, locals: locals})
    end
  end
  OpenStruct.new(content)
end

def slugify(value)
  value.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
end