require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "princely"
    gem.summary = %Q{A simple Rails wrapper for the PrinceXML PDF generation library.}
    gem.description = %Q{A wrapper for the PrinceXML PDF generation library.}
    gem.email = "michael@intridea.com"
    gem.homepage = "http://github.com/mbleigh/princely"
    gem.authors = ["Michael Bleigh"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec