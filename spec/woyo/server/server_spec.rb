require 'spec_helper.rb'
require 'woyo/server'

describe Woyo::Server, :type => :feature do

  before :all do
    @small_world = Woyo::World.new do
      location :small
    end
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
  end

  it 'requires a world' do
    visit '/'
    status_code.should eq 500
  end

  it 'accepts a world' do
    Woyo::Server.set :world, @small_world
    visit '/'
    status_code.should eq 200
  end

  it 'describes a location' do 
    Woyo::Server.set :world, @home_world
    visit '/'
    page.should have_selector '.location#location_home'
    page.should have_selector '.location#location_home .name',                      text: 'Home'
    page.should have_selector '.location#location_home .description',               text: 'Where the heart is.'
    page.should have_selector '.location#location_home .way#way_out'
    page.should have_selector '.location#location_home .way#way_out .name',         text: 'Door'
    page.should have_selector '.location#location_home .way#way_out .description',  text: 'A sturdy wooden door'
    page.should have_selector '.location#location_home .way#way_down'
    page.should have_selector '.location#location_home .way#way_down .name',        text: 'Stairs'
    page.should have_selector '.location#location_home .way#way_down .description', text: 'Rickety stairs lead down'
  end               

  it 'goes way to another location' do
    Woyo::Server.set :world, @home_world
    visit '/'
    page.should have_selector '.location#location_home .way#way_out a#go_out'
    click_on 'go_out'
    page.should have_selector '.location#location_garden .name', text: 'Garden'
  end

  it 'tracks location (go and come back)' do
    Woyo::Server.set :world, @home_world
    visit '/'
    page.should have_selector '.location#location_home .name',                text: 'Home'
    page.should have_selector '.location#location_home .way#way_out a#go_out'
    click_on 'go_out'
    page.should have_selector '.location#location_garden .name',              text: 'Garden'
    page.should have_selector '.location#location_garden .way#way_in a#go_in'
    click_on 'go_in'
    page.should have_selector '.location#location_home .name',                text: 'Home'
  end

  it 'tracks location (loop both directions)' do
    Woyo::Server.set :world, @home_world
    visit '/'
    page.should have_selector '.location#location_home .name',                text: 'Home'
    page.should have_selector '.location#location_home .way#way_out a#go_out'
    click_on 'go_out'
    page.should have_selector '.location#location_garden .name',              text: 'Garden'
    page.should have_selector '.location#location_garden .way#way_down a#go_down'
    click_on 'go_down'
    page.should have_selector '.location#location_cellar .name',              text: 'Cellar'
    page.should have_selector '.location#location_cellar .way#way_up a#go_up'
    click_on 'go_up'
    page.should have_selector '.location#location_home .name',                text: 'Home'
    page.should have_selector '.location#location_home .way#way_down a#go_down'
    click_on 'go_down'
    page.should have_selector '.location#location_cellar .name',              text: 'Cellar'
    page.should have_selector '.location#location_cellar .way#way_out a#go_out'
    click_on 'go_out'
    page.should have_selector '.location#location_garden .name',              text: 'Garden'
    page.should have_selector '.location#location_garden .way#way_in a#go_in'
    click_on 'go_in'
    page.should have_selector '.location#location_home .name',                text: 'Home'
  end

end

