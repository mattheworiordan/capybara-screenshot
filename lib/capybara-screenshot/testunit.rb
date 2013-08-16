require 'test/unit/testresult'
Test::Unit::TestResult.class_eval do

  private

  def notify_fault_with_screenshot(fault, *args)
    notify_fault_without_screenshot fault, *args
    if Capybara::Screenshot.autosave_on_failure
      filename_prefix = Capybara::Screenshot.filename_prefix_for(:testunit, fault)

      saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
      saver.save
    end
  end
  alias notify_fault_without_screenshot notify_fault
  alias notify_fault notify_fault_with_screenshot

end
