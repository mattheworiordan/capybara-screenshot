Spinach.hooks.before_scenario do |scenario|
  Capybara::Screenshot.final_session_name = nil
end

Spinach.hooks.on_failed_step do |step_data, exception, location, step_definitions|
  if Capybara::Screenshot.autosave_on_failure
    Capybara.using_session(Capybara::Screenshot.final_session_name) do
      filename_prefix = Capybara::Screenshot.filename_prefix_for(:spinach, step_data)
      saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
      saver.save
      saver.output_screenshot_path
    end
  end
end
