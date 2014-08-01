require_relative '../../../lib/woyo/server'
require 'spec_helper.rb'
require 'fileutils'

describe Woyo::Server, :type => :feature  do

  before :all do
    # directories
    @original_path = Dir.pwd
    File.basename(@original_path).should eq 'woyo-server'
    @test_dir = 'tmp/test'
    # worlds
    @small_world = Woyo::World.new do
      name "Small World"
      description "It's a small world after all."
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
          description 'Rickety stairs lead down into darkness. A dank smell emanates from the darkness below.'
          to :cellar
        end
        item :table do
          description 'A sturdy table.'
        end
        item :chair do
          description 'A comfortable chair.'
        end
        item :lamp do
          description 'A small lamp sits in darkness upon the table.'
          attribute light: false 
          action :switch do
            execute do
              light !light
            end
          end
        end
      end
      location :garden do
        name 'Garden'
        description 'A peaceful green oasis of life in the midst of a gray city.'
        way :in do
          name 'Door'
          description 'Door leads inside a cute cottage.'
          to :home
        end
        way :down do
          name 'Bulkhead'
          description 'Rusty bulkhead door and stairs.'
          to :cellar
        end
      end
      location :cellar do
        name 'Cellar'
        description 'Dark and damp, full of shadows and strange sounds.'
        way :out do
          name 'Bulkhead'
          description 'Rusty bulkhead stairs and door.'
          to :garden
        end
        way :up do
          name 'Stairs'
          description 'Rickety stairs lead up into light.'
          to :home
        end
      end
    end
  end

  # these must be the first tests so that Woyo::Server.setting.world is not set
  # that is why this file is named 1_server_spec.rb

  context 'with no world' do

    it 'welcome page is displayed if there is no world' do
      visit '/'
      status_code.should eq 200
      page.should have_content 'Woyo'
    end

    it 'welcome page links to github docs' do
      visit '/'
      status_code.should eq 200
      page.should have_link '', href: 'https://iqeo.github.io/woyo-world/'
      page.should have_link '', href: 'https://iqeo.github.io/woyo-server/'
    end

    it 'uses foundation framework' do
      visit '/'
      status_code.should eq 200
      page.should have_css 'head link[href="foundation-5.2.2/css/foundation.css"]'
      page.should have_css 'head script[src="foundation-5.2.2/js/vendor/modernizr.js"]'
    end

  end

  context 'loads the world' do

    it 'from files in directory' do
      content1 = "
        name 'Simple'
        start :one
        location :one do
          description 'First'
        end
      "
      content2 = "
        location :two do
          description 'Second'
        end
      "
      FileUtils.mkdir_p @test_dir
      File.write File.join( @test_dir, 'file1.rb' ), content1
      File.write File.join( @test_dir, 'file2.rb' ), content2
      world = nil
      expect { world = Woyo::Server.load_world File.join( @test_dir, '*.rb' ) }.to_not raise_error
      Woyo::Server.set :world, world
      visit '/'
      status_code.should eq 200
      page.should have_title /^Simple$/
    end

    it 'shows filename and lineno in backtrace upon error' do
      bad_world = "
        location :bad do
          raise 'boom'
        end
      "
      expect { Woyo::Server.eval_world bad_world, 'bad_world' }.to raise_error { |e|
        e.message.should eq 'boom'
        e.backtrace.first.should =~ /^bad_world.3/
      }
    end

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
      status_code.should eq 200
      page.should have_selector '.world .name',        text: "Small World"
      page.should have_selector '.world .description', text: "It's a small world after all."
      page.should have_selector '.world .no_start'
      page.should_not have_selector '.world .start'
    end

    it 'with start location' do
      @small_world.start = :small
      Woyo::Server.set :world, @small_world
      visit '/'
      status_code.should eq 200
      page.should have_selector '.world .name',                      text: "Small World"
      page.should have_selector '.world .description',               text: "It's a small world after all."
      page.should have_selector '.world .start a[href="/location"]', text: "Start"
      page.should_not have_selector '.world .no_start'
    end

  end

  context 'describes locations' do

    it 'title is location name'  do
      Woyo::Server.set :world, @small_world
      visit '/'
      click_on 'start'
      status_code.should eq 200
      page.should have_title /^Small$/
    end

    it 'start location' do 
      Woyo::Server.set :world, @home_world
      visit '/'
      click_on 'start'
      # save_page
      status_code.should eq 200
      page.should have_selector '.location#location-home .name',        text: 'Home'
      page.should have_selector '.location#location-home .description', text: 'Where the heart is.'
      page.should have_selector '.way#way-out .description',            text: 'A sturdy wooden door, '
      page.should have_selector '.way#way-down .description',           text: 'Rickety stairs lead down into darkness.'
      page.should have_selector '.item#item-table .description',        text: 'A sturdy table.'
      page.should have_selector '.item#item-chair .description',        text: 'A comfortable chair.'
      page.should have_selector '.item#item-lamp  .description',        text: 'A small lamp sits in darkness upon the table.'
      page.should have_selector '.action#action-item-lamp-switch .name', text: 'switch'
    end               

    context 'items' do

    end

    context 'actions' do

      before :all do
        @actions_world = Woyo::World.new do
          start :home
          location :home do
            item :lamp do
              description on:  "Lamp is on.",
                          off: "Lamp is off."
              exclusion :light, :off, :on 
              action :switch do
                description 'Turns the lamp on or off.'
                exclusion :result, :off, :on
                describe on:  'The lamp turns on.',
                         off: 'The lamp turns off.'
                execution do |this|
                  this.on = on        # sync switch with lamp
                  this.on = this.off  # toggle switch
                  on = off            # toggle lamp
                  { changes: :lamp }
                end
              end
            end
          end
        end
        Woyo::Server.set :world, @actions_world
      end

      before :each do
        visit '/'
        click_on 'start'
      end

      it 'have a name' do
        page.should have_selector '.action#action-item-lamp-switch .name', text: 'switch'
      end

      it 'have a link' do
        page.should have_selector '.action#action-item-lamp-switch a#do-item-lamp-switch'
      end

      it 'clicking link causes changes', :js => true do
        sleep 3
        page.should have_selector '.item#item-lamp .description', text: 'Lamp is off.'
        click_on 'do-item-lamp-switch'
        sleep 3
        page.should have_selector '.item#item-lamp .describe-actions', text: 'The lamp turns on.'
        sleep 3
        page.should have_selector '.item#item-lamp .description', text: 'Lamp is on.'
      end

    end

    context 'ways' do

      before :all do
        @ways_world = Woyo::World.new do
          start :home
          location :home do
            way :door do
              description open: 'A sturdy wooden door.',                       closed: 'Never closed'
              going       open: 'The door opens, leading to a sunlit garden.', closed: 'Never closed'
              to :garden
            end
            way :stairs do
              description closed: 'Broken stairs lead down into darkness.', open: 'Never open' 
              going       closed: 'The broken stairs are impassable.',      open: 'Never open' 
            end
            way :window do
              description 'A nice view.'
              going       'Makes no difference.'
              to :yard
            end
          end
        end
        Woyo::Server.set :world, @ways_world
      end

      context 'are described' do

        before :each do
          visit '/'
          click_on 'start'
          status_code.should eq 200
        end

        it 'open' do
          page.should have_selector '.way#way-door a#go-door'
          page.should have_selector '.way#way-door .description',  text: 'A sturdy wooden door.'
        end

        it 'closed' do
          page.should have_selector '.way#way-stairs a#go-stairs'
          page.should have_selector '.way#way-stairs .description',  text: 'Broken stairs lead down into darkness.'
        end

      end

      context 'are described with default' do

        it 'open' do
          window = @ways_world.locations[:home].ways[:window]
          window.open!
          window.should be_open
          visit '/'
          click_on 'start'
          status_code.should eq 200
          page.should have_selector '.way#way-window a#go-window'
          page.should have_selector '.way#way-window .description',  text: 'A nice view.'
        end

        it 'closed' do
          window = @ways_world.locations[:home].ways[:window]
          window.close!
          window.should be_closed
          visit '/'
          click_on 'start'
          status_code.should eq 200
          page.should have_selector '.way#way-window a#go-window'
          page.should have_selector '.way#way-window .description',  text: 'A nice view.'
        end

      end

      context 'are described going', :js => true do

        before :each do
          visit '/'
          page.find('body', visible: true)
          click_on 'start'
        end

        it 'open' do
          page.should have_selector '.way#way-door a#go-door'
          click_link 'go-door'
          page.should have_selector '.way#way-door .going',            text: 'The door opens, leading to a sunlit garden.' 
          sleep 3
          page.should have_selector '.location#location-garden .name', text: 'Garden'
        end

        it 'closed' do
          page.should have_selector '.way#way-stairs a#go-stairs'
          click_link 'go-stairs'
          page.should have_selector '.way#way-stairs .going',        text: 'The broken stairs are impassable.'
          page.should have_selector '.location#location-home .name', text: 'Home'
        end

      end

      context 'are described going with default', :js => true do

        it 'open' do
          window = @ways_world.locations[:home].ways[:window]
          window.open!
          window.should be_open
          visit '/'
          click_on 'start'
          page.should have_selector '.way#way-window a#go-window'
          click_link 'go-window'
          page.should have_selector '.way#way-window .going',        text: 'Makes no difference.' 
          sleep 3
          page.should have_selector '.location#location-yard .name', text: 'Yard'
        end

        it 'closed' do
          window = @ways_world.locations[:home].ways[:window]
          window.close!
          window.should be_closed
          visit '/'
          click_on 'start'
          page.should have_selector '.way#way-window a#go-window'
          click_link 'go-window'
          page.should have_selector '.way#way-window .going',        text: 'Makes no difference.' 
          page.should have_selector '.location#location-home .name', text: 'Home'
        end

      end

    end

  end

end

