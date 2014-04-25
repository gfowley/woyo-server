require 'woyo/runner'
require 'stringio'

describe Woyo::Runner do

  before :each do
    @output = StringIO.new
    @error  = StringIO.new
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

  it 'starts a world application server'

  it 'creates a world application directory'

  it 'prints help'

end
