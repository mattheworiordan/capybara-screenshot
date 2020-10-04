require "capybara-screenshot"

Before do |scenario|
  Capybara::Screenshot.final_session_name = nil
end

After do |scenario|
  if Capybara::Screenshot.autosave_on_failure && scenario.failed?
    Capybara.using_session(Capybara::Screenshot.final_session_name) do
      filename_prefix = Capybara::Screenshot.filename_prefix_for(:cucumber, scenario)

      saver = Capybara::Screenshot.new_saver(Capybara, Capybara.page, true, filename_prefix)
      saver.save
      saver.output_screenshot_path

      # Trying to embed the screenshot into our output."
      if File.exist?(saver.screenshot_path)
        require "base64"
        #encode the image into it's base64 representation
        image = open(saver.screenshot_path, 'rb') {|io|io.read}
        saver.display_image
        #this will embed the image in the HTML report, embed() is defined in cucumber
        encoded_img = Base64.encode64(image)

        # cucumber5 deprecates embed in favor of attach
        if respond_to? :attach
          attach(encoded_img, 'image/png')
        else
          embed(encoded_img, 'image/png;base64', "Screenshot of the error")
        end
      end
    end
  end
end
