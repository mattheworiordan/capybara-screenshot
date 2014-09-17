require 'rubygems'
require 'bundler/setup'

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'cucumber/rake/task'

# Cucumber will fail when run against an old version of GherkinRuby used by Spinach
begin
  require 'gherkin_ruby'
rescue LoadError
end

if defined?(GherkinRuby)
  Cucumber::Rake::Task.new(:features) do |t|
    if Cucumber::VERSION.match(/^1\.2/)
      t.cucumber_opts = "features"
    else
      t.cucumber_opts = "features --format pretty"
    end
  end
end

RSpec::Core::RakeTask.new(:spec)

task default: [:spec, :features]
