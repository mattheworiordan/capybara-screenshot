require 'capybara-screenshot/saver'

module Capybara
  module Screenshot
    module Cucumber
      extend self

      def screen_shot_and_save_page
        Capybara::Screenshot::Save.screen_shot_and_save_page(Capybara, Capybara.body)
      end

      def screen_shot_and_open_image
        saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.body, false)
        saver.save
        Launchy.open saver.screenshot_path
      end
      
    end
  end
end

World(Capybara::Screenshot::Cucumber)

After do |scenario|
  if Capybara::Screenshot.autosave_on_failure && scenario.failed?
    saver = Capybara::Screenshot::Save.new(Capybara, Capybara.body)
    saver.save
    screenshot_path = saver.screenshot_path

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