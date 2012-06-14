module Capybara
  module Screenshot
    class RSpec
      def self.screen_shot_and_save_page
        Capybara::Screenshot::Saver.screen_shot_and_save_page Capybara, Capybara.body
      end
    end
  end
end  

RSpec.configure do |config|
  config.after do
    if Capybara::Screenshot.autosave_on_failure && example.exception && example.metadata[:type] == :request
      saver = Capybara::Screenshot::Save.new(Capybara, Capybara.body)
      saver.save
      image = saver.screenshot_path

      example.metadata[:full_description] += "\n     Screenshot: #{image}"
    end
  end
end