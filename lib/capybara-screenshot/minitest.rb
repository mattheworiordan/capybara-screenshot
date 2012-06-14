require 'capybara-screenshot/saver'

if defined?(ActionDispatch::IntegrationTest)
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
        context.instance_eval do
          if Capybara::Screenshot.autosave_on_failure && @passed.blank?
            Capybara::Screenshot::Saver.screen_shot_and_save_page Capybara, Capybara.body
          end
        end
      end
    rescue NoMethodError
      # do nothing, teardown for minitest not available
    end
  end
end