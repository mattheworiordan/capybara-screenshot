require 'test/unit/testresult'

Test::Unit::TestCase.class_eval do
  setup do
    Capybara::Screenshot.final_session_name = nil
  end
end

Test::Unit::TestResult.class_eval do
  private

  def notify_fault_with_screenshot(fault, *args)
    notify_fault_without_screenshot fault, *args
    if fault.location.any? { |location| location =~ %r{test/integration} }
      if Capybara::Screenshot.autosave_on_failure
        Capybara.using_session(Capybara::Screenshot.final_session_name) do
          filename_prefix = Capybara::Screenshot.filename_prefix_for(:testunit, fault)

          saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
          saver.save
          saver.output_screenshot_path
        end
      end
    end
  end
  alias notify_fault_without_screenshot notify_fault
  alias notify_fault notify_fault_with_screenshot
end
