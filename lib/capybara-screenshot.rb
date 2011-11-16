# do nothing if Cucumber is not being used
if defined?(Cucumber::RbSupport::RbDsl)
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
end

if defined?(RSpec)
  # capybara rspec must be included first so that this config.after is added to
  #   RSpec hooks afterwards, and thus executed first
  require 'capybara/rspec'
  require 'capybara-screenshot/rspec'
  RSpec.configure do |config|
    config.after do
      unless Capybara.current_path.blank?
        Capybara::Screenshot::RSpec.screen_shot_and_save_page(Capybara.body)
      end
    end
  end
end