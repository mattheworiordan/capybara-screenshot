module Capybara
  module DSL
    # Adds class methods to Capybara module and gets mixed into
    # the current scope during Cucumber and RSpec tests

    def screen_shot_and_save_page
      Capybara::Screenshot.screen_shot_and_save_page
    end

    def screen_shot_and_open_image
      Capybara::Screenshot.screen_shot_and_open_image
    end
  end
end