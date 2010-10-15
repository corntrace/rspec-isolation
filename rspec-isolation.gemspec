# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rspec/isolation/version'

Gem::Specification.new do |s|
  s.name        = "rspec-isolation"
  s.version     = RSpec::Isolation::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kevin Fu"]
  s.email       = ["corntrace@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/rspec-isolation"
  s.summary     = "Make rspec examples run in separated processes."
  s.description = "Make rspec examples run in separated processes. \
    Especially used in framework development."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0.rc.5"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.require_path = 'lib'
  
  # s.add_dependency("rspec", ["~> 2.0.0"])
end