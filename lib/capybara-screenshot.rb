# do nothing if Cucumber is not being used
if defined?(Cucumber::RbSupport::RbDsl)
  require 'capybara/cucumber'
  require 'capybara-screenshot/cucumber'

  After do |scenario|
    if scenario.failed?
      screenshot_path = Capybara::Screenshot::Cucumber.screen_shot_and_save_page[:image]
      # Trying to embed the screenshot into our output."
      if File.exist?(screenshot_path)
        require "base64"
        #encode the image into it's base64 representation
        encoded_img = Base64.encode64(IO.read(screenshot_path))
        #this will embed the image in the HTML report, embed() is defined in cucumber
        embed("data:image/png;base64,#{encoded_img}", 'image/png', "Screenshot of the error")
      end
    end
  end
end

if defined?(RSpec)
  # capybara rspec must be included first so that this config.after is added to
  #   RSpec hooks afterwards, and thus executed first
  require 'capybara/rspec'
  require 'capybara-screenshot/rspec'
  RSpec.configure do |config|
    config.after do
      Capybara::Screenshot::RSpec.screen_shot_and_save_page if example.exception && example.metadata[:type] == 'request'
    end
  end
end

begin
  require 'minitest/unit'
  require 'capybara-screenshot/minitest'
rescue LoadError
  # mini test not available
end