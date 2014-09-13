require "spec_helper"
require "aruba/api"

describe "Using  Capybara::Screenshot with Test::Unit " do
  include Aruba::Api

  before do
    clean_current_dir
  end

  def run_failing_case(code)
    write_file('test/integration/test_failure.rb', <<-RUBY)
      require 'test/unit'
      require 'capybara'
      require 'capybara/rspec'
      require 'capybara-screenshot'
      require 'capybara-screenshot/testunit'
      require '../../../../spec/support/test_app'

      Capybara.app = TestApp
      Capybara.save_and_open_page_path = 'tmp'
      Capybara::Screenshot.append_timestamp = false
      Capybara::Screenshot.register_filename_prefix_formatter(:testunit) { 'my_screenshot' }

      class TestFailure < Test::Unit::TestCase
        include Capybara::DSL

        def test_failure
          #{code}
        end
      end
    RUBY

    cmd = 'ruby test/integration/test_failure.rb' # need to include the string test/integration
    expect(cmd).to include 'test/integration'
    run_simple cmd, false
    expect(output_from(cmd)).to include '1 error'
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
