require "spec_helper"

describe "Using Capybara::Screenshot with Spinach" do
  include CommonSetup

  def run_failing_case(failure_message, code)
    write_file('steps/failure.rb', <<-RUBY)
      #{ensure_load_paths_valid}
      require 'spinach/support/spinach_failure.rb'
      #{setup_test_app}
    RUBY

    write_file('spinach.feature', code)
    cmd = 'bundle exec spinach -f .'
    run_simple_with_retry cmd, false
    expect(last_command_started.output).to match(failure_message)
  end

  it "saves a screenshot on failure" do
    run_failing_case(%q{Unable to find visible link or button "you'll never find me"}, <<-GHERKIN)
      Feature: Failure
        Scenario: Failure
          Given I visit "/"
          And I click on a missing link
    GHERKIN
    expect('tmp/my_screenshot.html').to have_file_content('This is the root page')
  end

  it "saves a screenshot on an error" do
    run_failing_case(%q{you can't handle me}, <<-GHERKIN)
      Feature: Failure
        Scenario: Failure
          Given I visit "/"
          And I trigger an unhandled exception
    GHERKIN
    expect('tmp/my_screenshot.html').to have_file_content('This is the root page')
  end

  it "saves a screenshot for the correct session for failures using_session" do
    run_failing_case(%q{Unable to find visible link or button "you'll never find me"}, <<-GHERKIN)
      Feature: Failure
        Scenario: Failure in different session
          Given I visit "/"
          And I click on a missing link on a different page in a different session
    GHERKIN
    expect('tmp/my_screenshot.html').to have_file_content('This is a different page')
  end

  it 'on failure it prunes previous screenshots when strategy is set' do
    create_screenshot_for_pruning
    configure_prune_strategy :last_run
    run_failing_case(%q{Unable to find visible link or button "you'll never find me"}, <<-GHERKIN)
      Feature: Failure
        Scenario: Failure
          Given I visit "/"
          And I click on a missing link
    GHERKIN
    assert_screenshot_pruned
  end
end
