require_relative '../../../lib/woyo/server'
require 'spec_helper.rb'

describe Woyo::Server, :type => :feature do

  before :all do
    @small_world = Woyo::World.new do
      name "Small World"
      description "It's a small world after all"
      location :small
    end
    @home_world = Woyo::World.new do
      start :home
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

  # these must be the first tests so that Woyo::Server.setting.world is not set
  # that is why this file is name 1_server_spec.rb

  it 'welcome page is displayed if there is no world' do
    visit '/'
    status_code.should eq 200
    page.should have_content 'Woyo'
  end

  it 'welcome page links to github docs' do
    visit '/'
    status_code.should eq 200
    page.should have_link '', href: 'https://github.com/iqeo/woyo-world/wiki'
    page.should have_link '', href: 'https://github.com/iqeo/woyo-server/wiki'
  end

  it 'uses foundation framework' do
    visit '/'
    status_code.should eq 200
    page.should have_css 'head link[href="foundation/css/foundation.css"]'
    page.should have_css 'head script[src="foundation/js/vendor/modernizr.js"]'
  end

  context 'describes the world' do

    it 'title is world name' do
      Woyo::Server.set :world, @small_world
      visit '/'
      status_code.should eq 200
      page.should have_title /^Small World$/
    end

    it 'without start location' do
      Woyo::Server.set :world, @small_world
      visit '/'
      #STDOUT.puts page.html
      #save_page
      status_code.should eq 200
      page.should have_selector '.world .name',        text: "Small World"
      page.should have_selector '.world .description', text: "It's a small world after all"
      page.should have_selector '.world .no-start'
      page.should_not have_selector '.world .start'
    end

    it 'with start location' do
      @small_world.start = :small
      Woyo::Server.set :world, @small_world
      visit '/'
      status_code.should eq 200
      page.should have_selector '.world .name',                      text: "Small World"
      page.should have_selector '.world .description',               text: "It's a small world after all"
      page.should have_selector '.world .start a[href="/location"]', text: "Start"
      page.should_not have_selector '.world .no-start'
    end

    it 'shows file and lineno in stacktrace upon error loading world files'

  end

  context 'describes locations' do

    it 'title is location name'  do
      Woyo::Server.set :world, @small_world
      visit '/location'
      status_code.should eq 200
      page.should have_title /^Small$/
    end

    it 'start location' do 
      Woyo::Server.set :world, @home_world
      visit '/location'
      status_code.should eq 200
      page.should have_selector '.location#location_home'
      page.should have_selector '.location#location_home .name',                      text: 'Home'
      page.should have_selector '.location#location_home .description',               text: 'Where the heart is.'
      page.should have_selector '.way#way_out'
      page.should have_selector '.way#way_out .name',         text: 'Door'
      page.should have_selector '.way#way_out .description',  text: 'A sturdy wooden door'
      page.should have_selector '.way#way_down'
      page.should have_selector '.way#way_down .name',        text: 'Stairs'
      page.should have_selector '.way#way_down .description', text: 'Rickety stairs lead down'
    end               

    it 'goes way to another location' do
      Woyo::Server.set :world, @home_world
      visit '/location'
      status_code.should eq 200
      page.should have_selector '.way#way_out a#go_out'
      click_on 'go_out'
      status_code.should eq 200
      page.should have_selector '.location#location_garden .name', text: 'Garden'
    end

    it 'tracks location (go and come back)' do
      Woyo::Server.set :world, @home_world
      visit '/location'
      status_code.should eq 200
      page.should have_selector '.location#location_home .name',                text: 'Home'
      page.should have_selector '.way#way_out a#go_out'
      click_on 'go_out'
      status_code.should eq 200
      page.should have_selector '.location#location_garden .name',              text: 'Garden'
      page.should have_selector '.way#way_in a#go_in'
      click_on 'go_in'
      status_code.should eq 200
      page.should have_selector '.location#location_home .name',                text: 'Home'
    end

    it 'tracks location (loop both directions)' do
      Woyo::Server.set :world, @home_world
      visit '/location'
      status_code.should eq 200
      page.should have_selector '.location#location_home .name',                text: 'Home'
      page.should have_selector '.way#way_out a#go_out'
      click_on 'go_out'
      status_code.should eq 200
      page.should have_selector '.location#location_garden .name',              text: 'Garden'
      page.should have_selector '.way#way_down a#go_down'
      click_on 'go_down'
      status_code.should eq 200
      page.should have_selector '.location#location_cellar .name',              text: 'Cellar'
      page.should have_selector '.way#way_up a#go_up'
      click_on 'go_up'
      status_code.should eq 200
      page.should have_selector '.location#location_home .name',                text: 'Home'
      page.should have_selector '.way#way_down a#go_down'
      click_on 'go_down'
      status_code.should eq 200
      page.should have_selector '.location#location_cellar .name',              text: 'Cellar'
      page.should have_selector '.way#way_out a#go_out'
      click_on 'go_out'
      status_code.should eq 200
      page.should have_selector '.location#location_garden .name',              text: 'Garden'
      page.should have_selector '.way#way_in a#go_in'
      click_on 'go_in'
      status_code.should eq 200
      page.should have_selector '.location#location_home .name',                text: 'Home'
    end
  end

  context 'describes ways' do

    it 'going a closed way'

    it 'going an open way'

  end

end

