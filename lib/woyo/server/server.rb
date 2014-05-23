require 'sinatra/base'
require 'haml'
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
    redirect to 'default.html' if world.name.nil? && world.description.nil? && world.start.nil?
    @world = world
    haml :world
  end

  get '/location' do
    @location ||= world.locations[world.start]
    session[:location] = @location # fix: only store @location.id in session (cookie)
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
