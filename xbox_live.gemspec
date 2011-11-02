# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "xbox_live/version"

Gem::Specification.new do |s|
  s.name        = "xbox_live"
  s.version     = XboxLive::VERSION
  s.authors     = ["Mike Fischer"]
  s.email       = ["mikefischer99@gmail.com"]
  s.homepage    = "https://github.com/greendog99/xbox_live"
  s.summary     = %q{Xbox Live data retrieval}
  s.description = %q{Log into Xbox Live and retrieve information about a player}
  s.platform    = Gem::Platform::RUBY
  s.rubyforge_project = "xbox_live"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "mechanize", "~> 1.0"
  s.add_development_dependency "rspec", "~> 2.6"
end
