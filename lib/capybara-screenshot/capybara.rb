module Capybara
  module DSL
    # Adds class methods to Capybara module and gets mixed into
    # the current scope during Cucumber and RSpec tests

    def screenshot_and_save_page
      Capybara::Screenshot.screenshot_and_save_page
    end

    def screenshot_and_open_image
      Capybara::Screenshot.screenshot_and_open_image
    end
  end
end
