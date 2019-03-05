require "spec_helper"

describe "Using Capybara::Screenshot with Cucumber" do
  include CommonSetup

  let(:cmd) { 'cucumber' }

  def run_failing_case(failure_message, code)
    run_case code
    expect(last_command_started.output).to match(failure_message)
  end

  def run_case(code, options = {})
    write_file('features/support/env.rb', <<-RUBY)
      #{ensure_load_paths_valid}
      require 'cucumber/support/env.rb'
      #{setup_test_app}
    RUBY

    write_file('features/step_definitions/step_definitions.rb', <<-RUBY)
      %w(lib spec).each do |include_folder|
        $LOAD_PATH.unshift(File.join('#{gem_root}', include_folder))
      end
      require 'cucumber/step_definitions/step_definitions.rb'
    RUBY

    write_file('features/cucumber.feature', code)

    run_simple_with_retry cmd

    expect(last_command_started.output).to_not match(/failed|failure/i) if options[:assert_all_passed]
  end

  it 'saves a screenshot on failure' do
    run_failing_case %q{Unable to find (visible )?link or button "you'll never find me"}, <<-CUCUMBER
      Feature: Failure
        Scenario: Failure
          Given I visit "/"
          And I click on a missing link
    CUCUMBER
    expect('tmp/my_screenshot.html').to have_file_content('This is the root page')
  end

  it 'saves a screenshot on an error' do
    run_failing_case %q{you can't handle me}, <<-CUCUMBER
      Feature: Failure
        Scenario: Failure
          Given I visit "/"
          And I trigger an unhandled exception
    CUCUMBER
    expect('tmp/my_screenshot.html').to have_file_content('This is the root page')
  end

  it 'saves a screenshot for the correct session for failures using_session' do
    run_failing_case(%q{Unable to find (visible )?link or button "you'll never find me"}, <<-CUCUMBER)
      Feature: Failure
        Scenario: Failure in different session
          Given I visit "/"
          And I click on a missing link on a different page in a different session
    CUCUMBER
    expect('tmp/my_screenshot.html').to have_file_content('This is a different page')
  end

  context 'pruning' do
    before do
      create_screenshot_for_pruning
      configure_prune_strategy :last_run
    end

    it 'on failure it prunes previous screenshots when strategy is set' do
      run_failing_case %q{Unable to find (visible )?link or button "you'll never find me"}, <<-CUCUMBER
        Feature: Prune
          Scenario: Screenshots are pruned if strategy is set
            Given I visit "/"
            And I click on a missing link
      CUCUMBER
      assert_screenshot_pruned
    end

    it 'on success it never prunes' do
      run_case <<-CUCUMBER, assert_all_passed: true
        Feature: Prune
          Scenario: Screenshots are pruned if strategy is set
            Given I visit "/"
      CUCUMBER
      assert_screenshot_not_pruned
    end
  end
end
