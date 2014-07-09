require 'sinatra/base'
require 'sinatra/partial'
require 'haml'
require 'json'
require 'woyo/world'

module Woyo

class Server < Sinatra::Application

  def self.load_world glob = 'world/*.rb' 
    world = Woyo::World.new
    Dir[glob].each do |filename|
      eval_world File.read( filename ), filename, world
    end
    world
  end

  def self.eval_world text, filename, world = nil
    world ||= Woyo::World.new
    world.instance_eval text, filename
  end

  configure do
    enable :sessions
    set root: '.'
    set views: Proc.new { File.join(root, "views/server") }
    set public_folder: Proc.new { File.join(root, "public/server") }
    set world: self.load_world
  end

  def world
    settings.world
  end

  get '/' do
    redirect to 'default.html' if world.description.nil? && world.start.nil? # && world.name.nil? 
    @world = world
    session[:location_id] = world.start
    haml :world
  end

  get '/location' do
    @location = world.locations[session[:location_id]]
    haml :location
  end

  get '/go/*' do |way_id|
    way = world.locations[session[:location_id]].ways[way_id.to_sym]
    session[:location_id] = way.to.id if way.open?
    content_type :json
    way.go.to_json
  end

  get '/do/*/*?/*?' do |item,action,tool|
    # do default or optional action on required item with optional tool
  end
  
end

end
