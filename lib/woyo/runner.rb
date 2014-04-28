require_relative 'server'

module Woyo

class Runner

  def self.run args, out: $stdout, err: $stderr

    @args = args.dup
    @out = out
    @err = err

    code = case @args.first
      when 'new'     then mode_new
      when 'server'  then mode_server
      when 'console' then mode_console
      end
    return code if code
      
    if @args.empty? || @args.include?('-h') || @args.include?('--help')
      print_help
      return 0
    end

    if @args.include?('-v') || @args.include?('--version')
      print_version
      return 0
    end

  end

  def self.fail msg, code
    print_error msg
    return code
  end

  def self.mode_new
    if @args.include?('-h') || @args.include?('--help')
      print_help_new
      return 0
    end
    mode, dir = @args.shift 2
    if dir.nil?
      print_error 'No directory provided'
      return -1
    end
    if Dir.exists? dir
      unless @args.include?('-f') || @args.include?('--force')
        print_error 'Directory already exists'
        return -2 
      end
    end
    if File.exists? dir
      unless @args.include?('-f') || @args.include?('--force')
        print_error 'File exists with same name'
        return -3 
      end
    end
    [ 'public', 'views', 'world' ].each do |subdir|
      FileUtils.mkdir_p File.join( dir, subdir )
    end
    return 0
  end

  def self.mode_server
  end

  def self.mode_console
  end

  def self.print_help
    @err.puts "Usage: woyo ..."
    @err.puts
    @err.puts "............."
    @err.puts "............."
    @err.puts "............."
  end

  def self.print_help_new
    @err.puts "Usage: woyo new ..."
    @err.puts
    @err.puts "............."
    @err.puts "............."
    @err.puts "............."
  end

  def self.print_error msg
    @err.puts "Error: #{msg}"
  end

  def self.print_version
    @err.puts "woyo server version #{Woyo::SERVER_VERSION}"
    @err.puts "woyo world  version #{Woyo::WORLD_VERSION}"
  end

end

end

