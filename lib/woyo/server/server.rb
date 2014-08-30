require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/json'
require 'sinatra/reloader'
require 'erb'
require 'json'
require 'woyo/world'

module Woyo

class Server < Sinatra::Application

  WORLD_FILES = 'world/**/*.rb' 

  def self.load_world glob = WORLD_FILES
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
    # todo: sessions with server-side store instead of cookie
    enable :sessions
    set session_secret: SecureRandom.hex(16) 
    set root: '.'
    set views: Proc.new { File.join(root, "views/server") }
    set public_folder: Proc.new { File.join(root, "public/server") }
    set world: self.load_world
  end

  configure :development do
   register Sinatra::Reloader
   require 'pry'
  end

  def reload_world_changes
    # todo: get and track file adds, deletes, mtimes in WORLD_FILES 
  end

  before do
    if settings.development?
      reload_world_changes
    end
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
    erb :start
  end

  get '/play' do
    location
    erb :play
  end

  get '/locations/?:id?' do |id|
    ids = id ? [ id.to_sym ] : params[:ids] 
    ids = [ location.id ] unless false  # unless admin? a player can access current location only
    ids = ids.collect { |id| id.to_sym }
    locations = world.locations.select { |_,loc| ids.include? loc.id }     # old - id.nil? || ( loc.id == id ) }
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

  get '/items/?:id?' do |id|
    ids = id ? [ id.to_sym ] : params[:ids] 
    if ids && ! ids.empty?
      ids = ids.collect { |id| id.to_sym }
      items = location.items.select { |_,item| ids.include? item.id }
      json(
        {
          items:      items.collect do |_,item|
                        {
                          id:           item.id,
                          name:         item.name,
                          description:  item.description,
                          actions:      item.actions.keys
                        }
                      end.compact.uniq,
          actions:    items.collect do |_,item|
                        item.actions.collect do |_,action|
                          {
                            item:        item.id,   # wtf: can ember figure this out itself ?
                            id:          action.id,
                            name:        action.name,
                            description: action.description,
                            execution:   "item/#{item.id}/#{action.id}"
                          }
                        end
                      end.flatten.compact.uniq,
          executions: items.collect do |_,item|
                        item.actions.collect do |_,action|
                          {
                            action:      action.id, # wtf: can ember figure this out itself ?
                            id:          "item/#{item.id}/#{action.id}"
                          }
                        end   # empty execution so action will not be executed until clicked
                      end.flatten.compact.uniq
        }
      )
    end
  end

  get '/ways/?:id?' do |id|
    ids = id ? [ id.to_sym ] : params[:ids] 
    if ids && ! ids.empty?
      ids = ids.collect { |id| id.to_sym }
      ways = location.ways.select { |_,way| ids.include? way.id }
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

  get '/executions/*/*/*' do |owner_type,owner_id,action_id|
    content_type :json
    if location.children.include? owner_type.to_sym
      owner = location.send( owner_type, owner_id.to_sym )
      result = owner.action( action_id.to_sym ).execute
      # extract client-related info from execution hash
      if result[:execution].kind_of?( Hash )
        result[:changes] = result[:execution][:changes] ? Array(result[:execution][:changes]) : []
        # todo: detect location change in #execute
        if result[:execution][:location]
          session[:location_id] = result[:execution][:location]
          result[:changes] << :location
        end
      end
      result.delete :execution # execution info is for server only, do not pass to client
      result[:id] = "#{owner_type}/#{owner_id}/#{action_id}" 
      result[:action] = action_id
      json(
        {
          executions: result
        }
      )
    end
  end

  get '/go/*' do |way_id|
    content_type :json
    way = world.locations[session[:location_id]].ways[way_id.to_sym]
    session[:location_id] = way.to.id if way.open?
    way.go.to_json
  end

end

end
