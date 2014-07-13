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

  get '/do/*/*/*' do |owner_type,owner_id,action_id|
    initial_location_id = session[:location_id]
    location = world.locations[initial_location_id]
    if location.children.include? owner_type.to_sym
      owner = location.send( owner_type, owner_id.to_sym )
      owner.send action_id
      # action should return a hash containing...
      #   location: id    # if moving to a new location
      #   doing:    text  # description of action
      #   changes:  hash of changed attributes and values  # directly changed by action,  manual list or automatic detection via registerd listeners?
      #   affected: hash of affected attributes and values # hash attributes like 'description' select different value for changed attribute
      content_type :json
      { doing: owner.doing, change_location: true }.to_json
    end
  end
  
end

end
