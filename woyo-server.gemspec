# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'woyo/server/version'

Gem::Specification.new do |spec|
  spec.name          = "woyo-server"
  spec.version       = Woyo::SERVER_VERSION
  spec.authors       = ["Gerard Fowley"]
  spec.email         = ["gerard.fowley@iqeo.net"]
  spec.summary       = %q{World of Your Own}
  spec.description   = %q{Game world server}
  spec.homepage      = ""
  spec.license       = "GPLv3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test", "~> 0.6.2"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "selenium-webdriver"

  spec.add_runtime_dependency "woyo-world", ">= #{Woyo::SERVER_VERSION}"
  spec.add_runtime_dependency "sinatra", "~> 1.4.5"
  spec.add_runtime_dependency "sinatra-contrib", "~> 1.4.2"
  spec.add_runtime_dependency "sinatra-partial"
  spec.add_runtime_dependency "haml"

end
