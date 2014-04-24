require 'sinatra/base'
require 'haml'
require 'woyo/dsl'

module Woyo

class WebServer < Sinatra::Application

  configure do
    set root: '.'
    enable :sessions
  end

  def world
    raise 'No world provided' unless settings.respond_to? :world
    settings.world
  end

  get '/' do
    @location = world.location :home
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
