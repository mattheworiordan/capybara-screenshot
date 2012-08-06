# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capybara-screenshot/version"

Gem::Specification.new do |s|
  s.name        = "capybara-screenshot"
  s.version     = Capybara::Screenshot::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matthew O'Riordan"]
  s.email       = ["matthew.oriordan@gmail.com"]
  s.homepage    = "http://github.com/mattheworiordan/capybara-screenshot"
  s.summary     = %q{Automatically create snapshots when Cucumber steps fail with Capybara and Rails}
  s.description = %q{When a Cucumber step fails, it is useful to create a screenshot image and HTML file of the current page}

  s.rubyforge_project = "capybara-screenshot"

  s.add_dependency 'capybara', '>= 1.0'
  s.add_development_dependency 'rspec', '~> 2.7'
  s.add_development_dependency 'timecop'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
