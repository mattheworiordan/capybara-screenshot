require 'rubygems'
require 'bundler/setup'

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: [:spec]
