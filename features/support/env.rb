require 'rubygems'
require 'bundler/setup'

require_relative '../../spec/support/test_app'

require 'capybara/cucumber'
require 'capybara-screenshot'
require 'capybara-screenshot/cucumber'
require 'aruba/cucumber'
require 'aruba/jruby'

Capybara.save_and_open_page_path = 'tmp'
Capybara.app = TestApp

Before do
  @aruba_timeout_seconds = 60
end if RUBY_PLATFORM == 'java'

After('@restore-capybara-default-session') do
  Capybara.session_name = nil
end
