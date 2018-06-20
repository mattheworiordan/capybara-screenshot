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

    def using_session_with_screenshot(name,&blk)
      original_session_name = Capybara.session_name
      Capybara::Screenshot.final_session_name = name
      using_session_without_screenshot(name,&blk)
      Capybara::Screenshot.final_session_name = original_session_name
    end

    alias_method :using_session_without_screenshot, :using_session
    alias_method :using_session, :using_session_with_screenshot
  end
end
