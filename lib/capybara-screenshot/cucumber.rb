require "capybara-screenshot"
require 'mkmf'

Before do |scenario|
  Capybara::Screenshot.final_session_name = nil
end

After do |scenario|
  if Capybara::Screenshot.autosave_on_failure && scenario.failed?
    Capybara.using_session(Capybara::Screenshot.final_session_name) do
      filename_prefix = Capybara::Screenshot.filename_prefix_for(:cucumber, scenario)

      saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
      saver.save
      saver.output_screenshot_path

      # Trying to embed the screenshot into our output."
      if File.exist?(saver.screenshot_path)
        require "base64"
        #encode the image into it's base64 representation
        image = open(saver.screenshot_path, 'rb') {|io|io.read}
        #print image to screen, if imgcat is available
        system("imgcat #{saver.screenshot_path}") if find_executable 'imgcat'
        #this will embed the image in the HTML report, embed() is defined in cucumber
        encoded_img = Base64.encode64(image)
        embed(encoded_img, 'image/png;base64', "Screenshot of the error")
      end
    end
  end
end
