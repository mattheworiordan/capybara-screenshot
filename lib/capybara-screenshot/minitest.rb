method = if ActionDispatch::IntegrationTest.respond_to? :teardown
  :teardown
elsif ActionDispatch::IntegrationTest.respond_to? :add_tear_down_hook
  :add_tear_down_hook
end

unless method.nil?
  begin
    ActionDispatch::IntegrationTest.send method do |context|
      # by adding the argument context, MiniTest passes the context of the test
      # which has an instance variable @passed indicating success / failure
      failed = context.instance_variable_get(:@passed).blank?

      if Capybara::Screenshot.autosave_on_failure && failed
        filename_prefix = Capybara::Screenshot.filename_prefix_for(:minitest, context)

        saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
        saver.save

        if Capybara::Screenshot.open_on_failure
          Launchy.open(saver.screenshot_path)
        end
      end
    end
  rescue NoMethodError
    # do nothing, teardown for minitest not available
  end
end