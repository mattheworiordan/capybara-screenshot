require "capybara-screenshot"

module Capybara::Screenshot::MiniTestPlugin
  def before_setup
    super
    Capybara::Screenshot.final_session_name = nil
  end

  def before_teardown
    super
    if self.class.ancestors.map(&:to_s).include?('Capybara::DSL')
      if Capybara::Screenshot.autosave_on_failure && !passed? && !skipped?
        Capybara.using_session(Capybara::Screenshot.final_session_name) do
          filename_prefix = Capybara::Screenshot.filename_prefix_for(:minitest, self)

          saver = Capybara::Screenshot.new_saver(Capybara, Capybara.page, true, filename_prefix)
          saver.save
          saver.output_screenshot_path
        end
      end
    end
  end
end

begin
  Minitest.const_get('Test')
  class Minitest::Test
    include Capybara::Screenshot::MiniTestPlugin
  end
rescue NameError => e
  class MiniTest::Unit::TestCase
    include Capybara::Screenshot::MiniTestPlugin
  end
end


