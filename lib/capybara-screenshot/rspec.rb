RSpec.configure do |config|
  config.after(:each) do
    if [:request, :acceptance].include?(example.metadata[:type])
      if Capybara::Screenshot.autosave_on_failure && example.exception
        filename_prefix = Capybara::Screenshot.filename_prefix_for(:rspec, example)

        saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
        saver.save

        example.metadata[:full_description] += "\n     Screenshot: #{saver.screenshot_path}"
      end
    end
  end
end
