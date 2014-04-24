require 'sinatra/base'
require 'haml'
require 'woyo/dsl'

module Woyo

class WebServer < Sinatra::Application

  configure do
    set root: '.'
  end

  def world
    raise 'No world provided' unless settings.respond_to? :world
    settings.world
  end

  get '/' do
    @location = world.location :home
    haml :location
  end

  get '/go/*' do |way|
    # way.to location (from current location)
    @location = (world.location :home).ways[way.to_sym].to
    haml :location
  end

  get '/action/:thing' do
    # default action on thing
  end

end

end
