RSpec.configure do |config|
  config.after(:type => :request) do
    if Capybara::Screenshot.autosave_on_failure && example.exception
      saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page)
      saver.save

      example.metadata[:full_description] += "\n     Screenshot: #{saver.screenshot_path}"
    end
  end
end