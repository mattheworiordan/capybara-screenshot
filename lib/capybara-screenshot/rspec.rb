RSpec.configure do |config|
  config.after(:type => :request) do
    if Capybara::Screenshot.autosave_on_failure && example.exception
      filename_prefix = Capybara::Screenshot.filename_prefix_for(:rspec, example)

      saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
      saver.save

      example.metadata[:full_description] += "\n     Screenshot: #{saver.screenshot_path}"
    end
  end
end