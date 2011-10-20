require 'capybara/cucumber'
require 'capybara-screenshot/world'

module Capybara
  module Screenshot
  end
end

World(Capybara::Screenshot::World)

After do |scenario|
  screen_shot_and_save_page if scenario.failed?
end