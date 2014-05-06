require 'sinatra/base'
require 'haml'
require 'woyo/world'

module Woyo

class Server < Sinatra::Application

  def self.load_world
    world = Woyo::World.new
    Dir['world/*.rb'].each do |filename|
      world.instance_eval File.read filename
    end
    world
  end

  configure do
    enable :sessions
    set root: '.'
    set world: self.load_world
  end

  def world
    settings.world
  end

  get '/' do
    redirect to '/default.html' if world.locations.empty? || ( !@location && !world.start )
    @location ||= world.locations[world.start]
    session[:location] = @location
    haml :location
  end

  get '/go/*' do |way|
    @location = session[:location].ways[way.to_sym].to
    session[:location] = @location
    haml :location
  end

  get '/do/*/*?/*?' do |item,action,tool|
    # do default or optional action on required item with optional tool
  end
  
end

end
