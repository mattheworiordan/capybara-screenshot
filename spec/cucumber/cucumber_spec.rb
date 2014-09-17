require "spec_helper"

describe "Using Capybara::Screenshot with Cucumber" do
  include Aruba::Api

  let(:gem_root) { File.expand_path('../..', File.dirname(__FILE__)) }

  before do
    clean_current_dir
    if ENV['BUNDLE_GEMFILE'] && ENV['BUNDLE_GEMFILE'].match(/^\./)
      ENV['BUNDLE_GEMFILE'] = File.expand_path(ENV['BUNDLE_GEMFILE'].gsub(/^\./, gem_root))
    end
  end

  def run_failing_case(failure_message, code)
    write_file('features/support/env.rb', <<-RUBY)
      %w(lib spec).each do |include_folder|
        $LOAD_PATH.unshift(File.join('#{gem_root}', include_folder))
      end
      require 'cucumber/support/env.rb'
    RUBY

    write_file('features/step_definitions/step_definitions.rb', <<-RUBY)
      %w(lib spec).each do |include_folder|
        $LOAD_PATH.unshift(File.join('#{gem_root}', include_folder))
      end
      require 'cucumber/step_definitions/step_definitions.rb'
    RUBY

    write_file('features/cucumber.feature', code)
    cmd = 'bundle exec cucumber'
    run_simple cmd, false
    expect(output_from(cmd)).to match failure_message
  end

  it "saves a screenshot on failure" do
    run_failing_case(%q{Unable to find link or button "you'll never find me"}, <<-CUCUMBER)
      Feature: Failure
        Scenario: Failure
          Given I visit "/"
          And I click on a missing link
    CUCUMBER
    check_file_content('tmp/my_screenshot.html', 'This is the root page', true)
  end

  it "saves a screenshot on an error" do
    run_failing_case(%q{you can't handle me}, <<-CUCUMBER)
      Feature: Failure
        Scenario: Failure
          Given I visit "/"
          And I trigger an unhandled exception
    CUCUMBER
    check_file_content('tmp/my_screenshot.html', 'This is the root page', true)
  end

  it "saves a screenshot for the correct session for failures using_session" do
    run_failing_case(%q{Unable to find link or button "you'll never find me"}, <<-CUCUMBER)
      Feature: Failure
        Scenario: Failure in different session
          Given I visit "/"
          And I click on a missing link on a different page in a different session
    CUCUMBER
    check_file_content('tmp/my_screenshot.html', 'This is a different page', true)
  end
end
