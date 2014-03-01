RSpec.configure do |config|
  # use the before hook to add an after hook that runs last
  config.after do
    if Capybara.page.respond_to?(:save_page) # Capybara DSL method has been included for a feature we can snapshot
      if Capybara.page.current_url != '' && Capybara::Screenshot.autosave_on_failure && example.exception
        filename_prefix = Capybara::Screenshot.filename_prefix_for(:rspec, example)

        saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
        saver.save

        if Capybara::Screenshot.append_screenshot_path
          example.metadata[:full_description] += "\n     Screenshot: #{saver.screenshot_path}" if saver.screenshot_saved?
        end
      end
    end
  end
end
