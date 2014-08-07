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
    set :session_secret, SecureRandom.hex(16) 
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
    haml :start
  end

  get '/world' do
    haml :world
  end

  get '/locations' do
    content_type :json
    world.locations.collect { |id,loc| { id: id, name: loc.name } }.to_json
  end

  get '/location/*' do |id|
    content_type :json
    loc = world.location(id.to_sym)
    {
      id:          loc.id,
      name:        loc.name,
      description: loc.description
    }.to_json
  end

  # get '/location' do
  #   @location = world.locations[session[:location_id]]
  #   haml :location
  # end

  get '/go/*' do |way_id|
    content_type :json
    way = world.locations[session[:location_id]].ways[way_id.to_sym]
    session[:location_id] = way.to.id if way.open?
    way.go.to_json
  end

  get '/do/*/*/*' do |owner_type,owner_id,action_id|
    content_type :json
    initial_location_id = session[:location_id]
    location = world.locations[initial_location_id]
    if location.children.include? owner_type.to_sym
      owner = location.send( owner_type, owner_id.to_sym )
      result = owner.action( action_id.to_sym ).execute
      # extract client-related info from execution hash
      if result[:execution].kind_of?( Hash )
        result[:changes] = result[:execution][:changes] ? Array(result[:execution][:changes]) : []
        if result[:execution][:location]
          session[:location_id] = result[:execution][:location]
          result[:changes] << :location
        end
      end
      result.delete :execution # execution info is for server only, do not pass to client
      result.to_json  
    end
  end
  
end

end
