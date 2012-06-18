module Capybara
  module Screenshot
    module Cucumber

      def screen_shot_and_save_page
        Capybara::Screenshot.screen_shot_and_save_page
      end

      def screen_shot_and_open_image
        Capybara::Screenshot.screen_shot_and_open_image
      end
      
    end
  end
end
World(Capybara::Screenshot::Cucumber)

After do |scenario|
  if Capybara::Screenshot.autosave_on_failure && scenario.failed?
    saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page)
    saver.save

    # Trying to embed the screenshot into our output."
    if File.exist?(saver.screenshot_path)
      require "base64"
      #encode the image into it's base64 representation
      encoded_img = Base64.encode64(IO.read(saver.screenshot_path))
      #this will embed the image in the HTML report, embed() is defined in cucumber
      embed("data:image/png;base64,#{encoded_img}", 'image/png', "Screenshot of the error")
    end
  end
end