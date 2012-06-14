module Capybara
  module Screenshot
    class RSpec
      def self.screen_shot_and_save_page
        Capybara::Screenshot::Saver.screen_shot_and_save_page Capybara, Capybara.body
      end
    end
  end
end