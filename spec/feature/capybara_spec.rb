require 'spec_helper'

describe Capybara::Screenshot::RSpec, 'using with Capybara', type: :aruba do
  include CommonSetup

  before do
    Capybara::Screenshot.capybara_tmp_path = expand_path('tmp')
  end

  def run_failing_case(code, error_message, format=nil)
    run_case code, format: format
    if error_message.kind_of?(Regexp)
      expect(last_command_started.output).to match(error_message)
    else
      expect(last_command_started.output).to include(error_message)
    end
  end

  def run_case(code, options = {})
    write_file('spec/test_failure.rb', <<-RUBY)
      #{ensure_load_paths_valid}
      require 'rspec'
      require 'capybara'
      require 'capybara/rspec'
      require 'capybara-screenshot'
      require 'capybara-screenshot/rspec'

      require 'webdrivers'
      Capybara.register_driver :firefox do |app|
        options = Selenium::WebDriver::Firefox::Options.new
        options.args << '--headless'
        capabilities = Selenium::WebDriver::Remote::Capabilities.firefox({})

        Capybara::Selenium::Driver.new(
          app,
          browser: :firefox,
          capabilities: [capabilities, options],
        )
      end
      Capybara.default_driver = :firefox

      #{setup_test_app}
      #{code}
    RUBY

    cmd = cmd_with_format(options[:format])
    run_simple_with_retry cmd

    expect(last_command_started.output).to match('0 failures') if options[:assert_all_passed]
  end

  def cmd_with_format(format)
    "rspec #{"--format #{format} " if format}#{expand_path('spec/test_failure.rb')}"
  end

  # TODO: within_window did not have tests before
  it 'saves a screenshot for the correct window for failures ocurring inside within_window'

  it 'saves a screenshot for the correct frame for failures ocurring inside within_frame' do
    run_failing_case <<-RUBY, %r{Unable to find (visible )?link or button "you'll never find me"}
      RSpec.describe '/has_frame', type: :feature do
        it do
          visit '/has_frame'
          expect(page.body).to include('This is the has_frame page')

          within_frame 'different_page_frame' do
            puts page.body
            expect(page.body).to include('This is a different page')
            click_on "you'll never find me"
          end
        end
      end
    RUBY
    expect('tmp/screenshot.html').to have_file_content(/This is a different page/)
  end
end
