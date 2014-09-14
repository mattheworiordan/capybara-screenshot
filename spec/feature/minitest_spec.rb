require "spec_helper"
require "aruba/api"

describe "Using Capybara::Screenshot with MiniTest" do
  include Aruba::Api

  before do
    clean_current_dir
  end

  def run_failing_case(code)
    write_file('test_failure.rb', <<-RUBY)
      require 'minitest/autorun'
      require 'capybara'
      require 'capybara-screenshot'
      require 'capybara-screenshot/minitest'
      require '../../spec/support/test_app'

      Capybara.app = TestApp
      Capybara.save_and_open_page_path = 'tmp'
      Capybara::Screenshot.append_timestamp = false
      Capybara::Screenshot.register_filename_prefix_formatter(:minitest) { 'my_screenshot' }

      class TestFailure < Minitest::Unit::TestCase
        include Capybara::DSL

        def test_failure
          #{code}
        end
      end
    RUBY

    cmd = 'ruby test_failure.rb'
    run_simple cmd, false
    expect(output_from(cmd)).to include %q{Unable to find link or button "you'll never find me"}
  end

  it "saves a screenshot on failure" do
    run_failing_case <<-RUBY
      visit '/'
      assert(page.body.include?('This is the root page'))
      click_on "you'll never find me"
    RUBY
    check_file_content('tmp/my_screenshot.html', 'This is the root page', true)
  end

  it "saves a screenshot for the correct session for failures using_session" do
    run_failing_case <<-RUBY
      visit '/'
      assert(page.body.include?('This is the root page'))
      using_session :different_session do
        visit '/different_page'
        assert(page.body.include?('This is a different page'))
        click_on "you'll never find me"
      end
    RUBY
    check_file_content('tmp/my_screenshot.html', 'This is a different page', true)
  end
end
