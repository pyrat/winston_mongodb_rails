# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'winston_mongodb_rails/version'

 
Gem::Specification.new do |s|
  s.name        = "winston_mongodb_rails"
  s.version     = WinstonMongodbRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alastair Brunton"]
  s.email       = ["info@simplyexcited.co.uk"]
  s.homepage    = "http://github.com/pyrat/winston_mongodb_rails"
  s.summary     = "Port of the winston shared mongodb logger for rails."
  s.description = "This allows many applications to log to a shared mongodb logger. It is useful, if you have many small applications / load balanced applications and you want to treat a log as a first class citizen."
  
  s.add_dependency('mongo')
  
  s.required_rubygems_version = ">= 1.3.1"
  s.require_path = 'lib'
  s.files       = `git ls-files`.split("\n")
end