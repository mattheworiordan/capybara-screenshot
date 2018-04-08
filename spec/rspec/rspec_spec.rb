require 'spec_helper'

describe Capybara::Screenshot::RSpec, :type => :aruba do
  describe "used with RSpec" do
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

        #{setup_test_app}
        #{code}
      RUBY

      cmd = cmd_with_format(options[:format])
      run_simple_with_retry cmd, false

      expect(last_command_started.output).to match('0 failures') if options[:assert_all_passed]
    end

    def cmd_with_format(format)
      "rspec #{"--format #{format} " if format}#{expand_path('spec/test_failure.rb')}"
    end

    it 'saves a screenshot when browser action fails' do
      run_failing_case <<-RUBY, %q{Unable to find visible link or button "you'll never find me"}
        feature 'screenshot with failure' do
          scenario 'click on a missing link' do
            visit '/'
            expect(page.body).to include('This is the root page')
            click_on "you'll never find me"
          end
        end
      RUBY
      expect('tmp/screenshot.html').to have_file_content('This is the root page')
    end

    it 'saves a screenshot when expectation fails when using :aggregate_failures' do
      run_failing_case <<-RUBY, %q{expected "This is the root page" to include "you'll never find me"}
        feature 'screenshot with failure', :aggregate_failures do
          scenario 'expect a missing link' do
            visit '/'
            expect(page.body).to include("you'll never find me")
          end
        end
      RUBY
      expect('tmp/screenshot.html').to have_file_content('This is the root page')
    end

    formatters = {
      progress:      'HTML screenshot:',
      documentation: 'HTML screenshot:',
      html:          %r{<a href="file://\./tmp/screenshot\.html"[^>]*>HTML page</a>},
      json:          '"screenshot":{"'
    }

    # Textmate formatter is only included in RSpec 2
    if RSpec::Core::Version::STRING.to_i == 2
      formatters[:textmate] = %r{TextMate\.system\(.*open file://\./tmp/screenshot.html}
    end

    formatters.each do |formatter, error_message|
      it "uses the associated #{formatter} formatter" do
        run_failing_case <<-RUBY, error_message, formatter
          feature 'screenshot with failure' do
            scenario 'click on a missing link' do
              visit '/'
              click_on "you'll never find me"
            end
          end
        RUBY
        expect('tmp/screenshot.html').to have_file_content('This is the root page')
      end
    end

    it "does not save a screenshot for tests that don't use Capybara" do
      run_failing_case <<-RUBY, %q{expected: false}
        describe 'failing test' do
          it 'fails intentionally' do
            expect(true).to eql(false)
          end
        end
      RUBY
      expect('tmp/screenshot.html').to_not be_an_existing_file
    end

    it 'saves a screenshot for the correct session for failures using_session' do
      run_failing_case <<-RUBY, %q{Unable to find visible link or button "you'll never find me"}
        feature 'screenshot with failure' do
          scenario 'click on a missing link' do
            visit '/'
            expect(page.body).to include('This is the root page')
            using_session :different_session do
              visit '/different_page'
              expect(page.body).to include('This is a different page')
              click_on "you'll never find me"
            end
          end
        end
      RUBY
      expect('tmp/screenshot.html').to have_file_content(/is/)
    end

    context 'pruning' do
      before do
        create_screenshot_for_pruning
        configure_prune_strategy :last_run
      end

      it 'on failure it prunes previous screenshots when strategy is set' do
        run_failing_case <<-RUBY, 'HTML screenshot:', :progress
          feature 'screenshot with failure' do
            scenario 'click on a missing link' do
              visit '/'
              click_on "you'll never find me"
            end
          end
        RUBY
        assert_screenshot_pruned
      end

      it 'on success it never prunes' do
        run_case <<-CUCUMBER, assert_all_passed: true
          feature 'screenshot without failure' do
            scenario 'click on a link' do
              visit '/'
            end
          end
        CUCUMBER
        assert_screenshot_not_pruned
      end
    end

    context 'no pruning by default' do
      before do
        create_screenshot_for_pruning
      end

      it 'on failure it leaves existing screenshots' do
        run_failing_case <<-RUBY, 'HTML screenshot:', :progress
          feature 'screenshot with failure' do
            scenario 'click on a missing link' do
              visit '/'
              click_on "you'll never find me"
            end
          end
        RUBY
        assert_screenshot_not_pruned
      end
    end
  end
end
