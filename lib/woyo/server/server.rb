require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/json'
require 'sinatra/reloader'
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

  configure :development do
   register Sinatra::Reloader
   # also_reload 'world/*.rb' # will need a custom loader like self.load_world for individual files
   require 'pry'
  end

  def world
    @world = settings.world
  end

  def location
    @location = world.locations[session[:location_id]]
  end

  def set_location id
    session[:location_id] = id
    location 
  end

  get '/' do
    redirect to 'default.html' if world.description.nil? && world.start.nil? # && world.name.nil? 
    set_location world.start
    haml :start
  end

  get '/world' do
    haml :world
  end

  get '/locations/?:id?' do |id|
    id = id.to_sym unless id.nil?
    set_location world.start
    locations = world.locations.select { |_,loc| id.nil? || ( loc.id == id ) }
    json(
      {
        locations:  locations.collect do |_,loc|
                      {
                        id:           loc.id,
                        name:         loc.name,
                        description:  loc.description,
                        ways:         loc.ways.keys,
                        items:        loc.items.keys
                      }
                    end
      }
    )
  end

  get '/items' do
    ids = params[:ids]
    if ids && ! ids.empty?
      json(
        {
          items: location.items.collect do |_,item|
            {
              id:           item.id,
              name:         item.name,
              description:  item.description
            }
          end.compact.uniq
        }
      )
    end
  end

  get '/ways' do
    ids = params[:ids]
    if ids && ! ids.empty?
      json(
        {
          ways: location.ways.collect do |_,way|
            {
              id:           way.id,
              name:         way.name,
              description:  way.description
            }
          end.compact.uniq
        }
      )
    end
  end

=begin
    actions: item.actions.collect do |id,action|
      {
        id:          action.id,
        name:        action.name,
        description: action.description
      }
    end
=end

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
