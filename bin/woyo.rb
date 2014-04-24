#! /usr/bin/env ruby

require 'woyo/dsl'
require 'woyo/server'

@home_world = Woyo::World.new do
  location :home do
    name 'Home'
    description 'Where the heart is.'
    way :out do
      name 'Door'
      description 'A sturdy wooden door, old fashioned farmhouse style of a bygone era.'
      to :garden
    end
    way :down do
      name 'Stairs'
      description 'Rickety stairs lead down into darkness. A dank smell emanates from the darkness below'
      to :cellar
    end
  end
  location :garden do
    name 'Garden'
    description 'A peaceful green oasis of life in the midst of a gray city'
    way :in do
      name 'Door'
      description 'Door leads inside a cute cottage'
      to :home
    end
    way :down do
      name 'Bulkhead'
      description 'Rusty bulkhead door and stairs'
      to :cellar
    end
  end
  location :cellar do
    name 'Cellar'
    description 'Dark and damp, full of shadows and strange sounds'
    way :out do
      name 'Bulkhead'
      description 'Rusty bulkhead stairs and door'
      to :garden
    end
    way :up do
      name 'Stairs'
      description 'Rickety stairs lead up into light'
      to :home
    end
  end
end

Woyo::Server::Server.set :world, @home_world
Woyo::Server::Server.run!

