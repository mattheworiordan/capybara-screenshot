require "spec_helper"

describe "Using Capybara::Screenshot with MiniTest" do
  include CommonSetup

  def run_failing_case(code)
    write_file('test_failure.rb', <<-RUBY)
      #{ensure_load_paths_valid}
      require 'minitest/autorun'
      require 'capybara'
      require 'capybara-screenshot'
      require 'capybara-screenshot/minitest'

      #{setup_test_app}
      Capybara::Screenshot.register_filename_prefix_formatter(:minitest) do |test_case|
        test_name = test_case.respond_to?(:name) ? test_case.name : test_case.__name__
        raise "expected fault" unless test_name.include? 'test_failure'
        'my_screenshot'
      end

      #{code}
    RUBY

    cmd = 'bundle exec ruby test_failure.rb'
    run_simple_with_retry cmd
    expect(last_command_started.output).to match %r{Unable to find (visible )?link or button "you'll never find me"}
  end

  it 'saves a screenshot on failure' do
    run_failing_case <<-RUBY
      class TestFailure < MiniTest::Unit::TestCase
        include Capybara::DSL

        def test_failure
          visit '/'
          assert(page.body.include?('This is the root page'))
          click_on "you'll never find me"
        end
      end
    RUBY
    expect('tmp/my_screenshot.html').to have_file_content('This is the root page')
  end

  it 'saves a screenshot for the correct session for failures using_session' do
    run_failing_case <<-RUBY
      class TestFailure < Minitest::Unit::TestCase
        include Capybara::DSL

        def test_failure
          visit '/'
          assert(page.body.include?('This is the root page'))
          using_session :different_session do
            visit '/different_page'
            assert(page.body.include?('This is a different page'))
            click_on "you'll never find me"
          end
        end
      end
    RUBY
    expect('tmp/my_screenshot.html').to have_file_content('This is a different page')
  end

  it 'prunes screenshots on failure' do
    create_screenshot_for_pruning
    configure_prune_strategy :last_run
    run_failing_case <<-RUBY
      class TestFailure < Minitest::Unit::TestCase
        include Capybara::DSL

        def test_failure
          visit '/'
          assert(page.body.include?('This is the root page'))
          click_on "you'll never find me"
        end
      end
    RUBY
    assert_screenshot_pruned
  end
end
