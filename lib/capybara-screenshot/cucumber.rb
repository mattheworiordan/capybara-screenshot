require 'launchy'

After do |scenario|
  if Capybara::Screenshot.autosave_on_failure && scenario.failed?
    filename_prefix = Capybara::Screenshot.filename_prefix_for(:cucumber, scenario)

    saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
    saver.save

    # Trying to embed the screenshot into our output."
    if File.exist?(saver.screenshot_path)
      require "base64"
      #encode the image into it's base64 representation
      encoded_img = Base64.encode64(IO.read(saver.screenshot_path))
      #this will embed the image in the HTML report, embed() is defined in cucumber
      embed("data:image/png;base64,#{encoded_img}", 'image/png', "Screenshot of the error")

      if Capybara::Screenshot.open_on_failure
        Launchy.open(saver.screenshot_path)
      end
    end
  end
end