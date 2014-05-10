require_relative '../../../lib/woyo/runner'
require 'fileutils'
require 'stringio'
require 'open-uri'

STDERR.sync = true
STDERR.sync = true

describe Woyo::Runner do

  before :each do
    @output = StringIO.new
    @error  = StringIO.new
  end

  before :all do
    @expected_entries = [ 'public', 'views', 'world' ]
    @contents = {
      '.'             => %w( . .. world views public ),
      'world'         => %w( . .. .gitkeep ),
      'views'         => %w( . .. app server ),
      'views/app'     => %w( . .. .gitkeep ),
      'views/server'  => %w( . .. layout.haml location.haml ),
      'public'        => %w( . .. app server ),
      'public/app'    => %w( . .. html images js css ),
      'public/server' => %w( . .. default.html foundation foundation-5.2.2 jquery jquery-2.1.1 ),
    }
    @original_path = Dir.pwd
    File.basename(@original_path).should eq 'woyo-server'
    @test_dir = 'tmp/test'
  end

  it 'prints a helpful message to stderr for help (-h/--help) switch' do
    [['-h'],['--help']].each do |args|
      Woyo::Runner.run( args, out: @output, err: @error ).should eq 0
      @error.string.should include 'woyo'
    end
  end

  it 'prints version info to stderr for version (-v/--version) switch' do
    [['-v'],['--version']].each do |args|
      Woyo::Runner.run( args, out: @output, err: @error ).should eq 0
      @error.string.should include 'woyo'
      @error.string.should include Woyo::SERVER_VERSION 
      @error.string.should include Woyo::WORLD_VERSION 
    end
  end

  context 'new' do

    before :each do
      Dir.pwd.should eq @original_path
      FileUtils.rm_rf @test_dir
      FileUtils.mkdir_p @test_dir
      Dir.chdir @test_dir
      Dir.pwd.should eq File.join( @original_path, @test_dir )
    end

    after :each do
      Dir.chdir @original_path
      Dir.pwd.should eq @original_path
    end

    it 'requires a directory be specified' do
      Woyo::Runner.run( ['new'], out: @output, err: @error ).should eq -1
    end

    it 'creates a world application directory' do
      [['new','testworld'],['new','test/testworld']].each do |cmd,dir|
        Woyo::Runner.run( [cmd,dir], out: @output, err: @error ).should eq 0
        Dir.should exist dir
        Dir.entries(dir).sort.should eq @contents['.'].sort
      end
    end

    it 'populates directories' do
      Woyo::Runner.run( ['new','testworld'], out: @output, err: @error ).should eq 0
      @contents.each do |dir,contents|
        Dir.entries(File.join('testworld',dir)).sort.should eq contents.sort
      end
    end

    it 'requires force (-f/--force) for existing directory' do
      [['new','testworld'],['new','test/testworld'],['new','.']].each do |args|
        dir = args[1]
        FileUtils.mkdir_p dir
        Dir.should exist dir
        Woyo::Runner.run( args, out: @output, err: @error ).should eq -2
        [['--force'],['-f']].each do |force|
          FileUtils.mkdir_p dir
          Dir.should exist dir
          Woyo::Runner.run( args + force, out: @output, err: @error ).should eq 0
          Dir.should exist dir
          (Dir.entries(dir) & @expected_entries).sort.should eq @expected_entries
          FileUtils.rm_rf dir
        end                                     
      end
    end

    it 'refuses for existing file' do
      [['new','testworld'],['new','test/testworld']].each do |args|
        dir = args[1]
        FileUtils.mkdir_p File.dirname(dir)
        FileUtils.touch dir 
        File.should exist dir
        Woyo::Runner.run( args, out: @output, err: @error ).should eq -3
      end
    end

    it 'help (-h/--help) explains new command' do
      [['-h'],['--help']].each do |help|
        Woyo::Runner.run( ['new'] + help, out: @output, err: @error ).should eq 0
        @error.string.should include 'woyo new'
      end
    end

  end

  context 'server' do

    before :all do
      Dir.pwd.should eq @original_path
      FileUtils.rm_rf @test_dir
      FileUtils.mkdir_p @test_dir
      Dir.chdir @test_dir
      Dir.pwd.should eq File.join( @original_path, @test_dir )
      Woyo::Runner.run( ['new','testworld'], out: @output, err: @error ).should eq 0
      Dir.chdir 'testworld'
      @this_world_path = File.join( @original_path, @test_dir, 'testworld' )
      Dir.pwd.should eq @this_world_path
    end

    before :each do
      Dir.chdir @this_world_path
      Dir.pwd.should eq @this_world_path
    end

    after :all do
      Dir.chdir @original_path
      Dir.pwd.should eq @original_path
    end

    it 'must be run within a world application directory' do
      Dir.chdir '..'
      Woyo::Runner.run( ['server'], out: @output, err: @error ).should eq -4  
    end

    it 'starts a world application server' do
      thread = Thread.new { Woyo::Runner.run( ['server'], out: @output, err: @error ) }
      thread.should be_alive
      sleep 2 
      @error.string.should include 'has taken the stage'
      Woyo::Server.set :world, Woyo::World.new { start :home ; location(:home) { name 'Home' } }
      page = ''
      expect { page = open("http://127.0.0.1:4567/").read }.to_not raise_error
      page.should include 'Home'
      Woyo::Server.stop!
      thread.join
    end

    it 'help (-h/--help) explains server command' do
      [['-h'],['--help']].each do |help|
        Woyo::Runner.run( ['server'] + help, out: @output, err: @error ).should eq 0
        @error.string.should include 'woyo server'
      end
    end

  end

  context 'console' do

    before :all do
      Dir.pwd.should eq @original_path
      FileUtils.rm_rf @test_dir
      FileUtils.mkdir_p @test_dir
      Dir.chdir @test_dir
      Dir.pwd.should eq File.join( @original_path, @test_dir )
      Woyo::Runner.run( ['new','testworld'], out: @output, err: @error ).should eq 0
      Dir.chdir 'testworld'
      Dir.pwd.should eq File.join( @original_path, @test_dir, 'testworld' )
    end

    after :all do
      Dir.chdir @original_path
      Dir.pwd.should eq @original_path
    end

    it 'must be run within a world application directory' do
      Dir.chdir '..'
      Woyo::Runner.run( ['console'], out: @output, err: @error ).should eq -4
    end
    
    # it 'starts a world application console'

    # it 'help (-h/--help) explains console command' do
    #   [['-h'],['--help']].each do |help|
    #     Woyo::Runner.run( ['console'] + help, out: @output, err: @error ).should eq 0
    #     @error.string.should include 'woyo console'
    #   end
    # end

  end

  context 'update' do

    before :all do
      Dir.pwd.should eq @original_path
      FileUtils.rm_rf @test_dir
      FileUtils.mkdir_p @test_dir
      Dir.chdir @test_dir
      Dir.pwd.should eq File.join( @original_path, @test_dir )
      Woyo::Runner.run( ['new','testworld'], out: @output, err: @error ).should eq 0
      Dir.chdir 'testworld'
      @this_world_path = File.join( @original_path, @test_dir, 'testworld' )
      Dir.pwd.should eq @this_world_path
    end

    before :each do
      Dir.chdir @this_world_path
      Dir.pwd.should eq @this_world_path
    end

    after :all do
      Dir.chdir @original_path
      Dir.pwd.should eq @original_path
    end

    it 'runs in a world application directory' do
      Woyo::Runner.run( ['update'], out: @output, err: @error ).should eq 0
    end

    it 'updates existing standard files and directories' do
      before = Time.now - 30 # new directory was deployed within last 60 seconds
      Woyo::Runner.run( ['update'], out: @output, err: @error ).should eq 0
      @contents.each do |dir,contents|
        contents.each do |file|
          unless ['.','..'].include?( file ) || File.symlink?( File.join(dir,file) )
            File.mtime(File.join(dir,file)).should be < before 
          end
        end
      end
    end

    it 'replaces missing standard files and directories' do
      FileUtils.rm_rf 'views/server'
      FileUtils.rm_rf 'public/server'
      Woyo::Runner.run( ['update'], out: @output, err: @error ).should eq 0
      @contents.each do |dir,contents|
        contents.each do |file|
          File.should exist File.join(dir,file)
        end
      end
    end

    it 'preserves custom files and directories' do
      custom = %w( world/custom.rb views/app/custom.haml public/app/html/custom.html public/app/images/custom.png public/app/js/custom.js public/app/css/custom.css )
      custom.each { |f| FileUtils.touch f }
      Woyo::Runner.run( ['update'], out: @output, err: @error ).should eq 0
      custom.each { |f| File.should exist f } 
    end

    it 'must be run within a world application directory' do
      FileUtils.mkdir_p '../not-a-server'
      Dir.chdir '../not-a-server'
      Woyo::Runner.run( ['update'], out: @output, err: @error ).should eq -4
    end

    it 'requires force (-f/--force) to run in incomplete or non world application directory' do
      FileUtils.mkdir_p '../not-a-server'
      Dir.chdir '../not-a-server'
      Woyo::Runner.run( ['update','--force'], out: @output, err: @error ).should eq 0
      FileUtils.mkdir_p '../also-not-a-server'
      Dir.chdir '../also-not-a-server'
      Woyo::Runner.run( ['update','-f'], out: @output, err: @error ).should eq 0
    end

    it 'help (-h/--help) explains update command' do
      [['-h'],['--help']].each do |help|
        Woyo::Runner.run( ['update'] + help, out: @output, err: @error ).should eq 0
        @error.string.should include 'woyo update'
      end
    end

  end
end
