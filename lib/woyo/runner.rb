require_relative 'server'

module Woyo

class Runner

  def self.run args, out: $stdout, err: $stderr

    if args.empty? || args.include?('-h') || args.include?('--help')
      print_help err
      return 0
    end

    if args.include?('-v') || args.include?('--version')
      print_version err
      return 0
    end

  end

  def self.print_help io
    io.puts "Usage: woyo..."
    io.puts
    io.puts "............."
    io.puts "............."
    io.puts "............."
  end

  def self.print_version io
    io.puts "woyo server version #{Woyo::SERVER_VERSION}"
    io.puts "woyo world  version #{Woyo::WORLD_VERSION}"
  end

end

end

