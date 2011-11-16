require 'capybara-screenshot/saver'

module Capybara
  module Screenshot
    module World
      def screen_shot_and_save_page
        Capybara::Screenshot::Saver.screen_shot_and_save_page Capybara, Capybara.body
      end
    end
  end
end