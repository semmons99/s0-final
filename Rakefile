require 'rubygems'
require 'rake'
require 'rake/clean'

CLOBBER.include('.yardoc', 'doc', '*.gem')

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :default => :spec

require 'cucumber/rake/task'
Cucumber::Rake::Task.new

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
