require 'capybara-screenshot/saver'

module Capybara
  module Screenshot
    class RSpec
      def self.screen_shot_and_save_page(body)
        Capybara::Screenshot::Saver.screen_shot_and_save_page Capybara, Capybara.body
      end
    end
  end
end