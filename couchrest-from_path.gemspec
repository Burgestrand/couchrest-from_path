# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'couchrest-from_path/version'

Gem::Specification.new do |s|
  s.name        = "couchrest-from_path"
  s.version     = CouchRest::FromPath::VERSION 
  s.authors     = ["Kim Burgestrand"]
  s.email       = ["kim@burgestrand.se"]
  s.homepage    = "https://github.com/Burgestrand/couchrest-from_path"
  s.summary     = %q{Allows you to create a CouchRest::Document from a path}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'couchrest', '~> 1.0'
  s.add_development_dependency 'rspec', '~> 2.0'
  s.add_development_dependency 'fakefs'
end
