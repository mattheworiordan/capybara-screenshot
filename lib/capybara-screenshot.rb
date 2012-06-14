module Capybara
  module Screenshot
    mattr_accessor :autosave_on_failure
    self.autosave_on_failure = true
  end
end

require 'capybara-screenshot/saver'

# do nothing if Cucumber is not being used
if defined?(Cucumber::RbSupport::RbDsl)
  require 'capybara/cucumber'
  require 'capybara-screenshot/cucumber'
end

if defined?(RSpec)
  # capybara rspec must be included first so that this config.after is added to
  #   RSpec hooks afterwards, and thus executed first
  require 'capybara/rspec'
  require 'capybara-screenshot/rspec'
  
  RSpec.configure do |config|
    config.after do
      if Capybara::Screenshot.autosave_on_failure && example.exception && example.metadata[:type] == :request
        image = Capybara::Screenshot::RSpec.screen_shot_and_save_page[:image]
        example.metadata[:full_description] += "\n     Screenshot: #{image}"
      end
    end
  end
end

begin
  require 'minitest/unit'
  require 'capybara-screenshot/minitest'
rescue LoadError
  # mini test not available
end
