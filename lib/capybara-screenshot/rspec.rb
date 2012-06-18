RSpec.configure do |config|
  config.after do
    if Capybara::Screenshot.autosave_on_failure && example.exception && example.metadata[:type] == :request
      saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page)
      saver.save
      image = saver.screenshot_path

      example.metadata[:full_description] += "\n     Screenshot: #{image}"
    end
  end
end