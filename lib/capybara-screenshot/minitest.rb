setup_method = if ActionDispatch::IntegrationTest.respond_to? :teardown
  :setup
elsif ActionDispatch::IntegrationTest.respond_to? :add_tear_down_hook
  :add_setup_hook
end

unless setup_method.nil?
  begin
    ActionDispatch::IntegrationTest.send setup_method do |context|
      Capybara::Screenshot.final_session_name = nil
    end
  rescue NoMethodError
    # do nothing, setup for minitest not available
  end
end

teardown_method = if ActionDispatch::IntegrationTest.respond_to? :teardown
  :teardown
elsif ActionDispatch::IntegrationTest.respond_to? :add_tear_down_hook
  :add_tear_down_hook
end

unless teardown_method.nil?
  begin
    ActionDispatch::IntegrationTest.send teardown_method do |context|
      # by adding the argument context, MiniTest passes the context of the test
      # which has an instance variable @passed indicating success / failure
      failed = !context.passed?

      if Capybara::Screenshot.autosave_on_failure && failed
        Capybara.using_session(Capybara::Screenshot.final_session_name) do
          filename_prefix = Capybara::Screenshot.filename_prefix_for(:minitest, context)

          saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
          saver.save
          saver.output_screenshot_path
        end
      end
    end
  rescue NoMethodError
    # do nothing, teardown for minitest not available
  end
end
