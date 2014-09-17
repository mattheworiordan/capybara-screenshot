require 'spec_helper'

describe Capybara::Screenshot::RSpec do
  describe "used with RSpec" do
    include Aruba::Api
    include CommonSetup

    before do
      clean_current_dir
    end

    def run_failing_case(code, error_message, format=nil)
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

      cmd = "bundle exec rspec #{"--format #{format} " if format}spec/test_failure.rb"
      run_simple cmd, false

      if error_message.kind_of?(Regexp)
        expect(output_from(cmd)).to match(error_message)
      else
        expect(output_from(cmd)).to include(error_message)
      end
    end

    it "saves a screenshot on failure" do
      run_failing_case <<-RUBY, %q{Unable to find link or button "you'll never find me"}
        feature 'screenshot with failure' do
          scenario 'click on a missing link' do
            visit '/'
            expect(page.body).to include('This is the root page')
            click_on "you'll never find me"
          end
        end
      RUBY
      check_file_content('tmp/screenshot.html', 'This is the root page', true)
    end

    {
      progress:      "HTML screenshot:",
      documentation: "HTML screenshot:",
      html:          %r{<a.*>HTML page</a>},
      textmate:      %r{TextMate\.system\(.*open file://\./tmp/screenshot.html}
    }.each do |formatter, error_message|
      it "uses the associated #{formatter} formatter" do
        run_failing_case <<-RUBY, error_message, formatter
          feature 'screenshot with failure' do
            scenario 'click on a missing link' do
              visit '/'
              click_on "you'll never find me"
            end
          end
        RUBY
        check_file_content('tmp/screenshot.html', 'This is the root page', true)
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
      check_file_presence(%w{tmp/screenshot.html}, false)
    end

    it "saves a screenshot for the correct session for failures using_session" do
      run_failing_case <<-RUBY, %q{Unable to find link or button "you'll never find me"}
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
      check_file_content('tmp/screenshot.html', 'This is a different page', true)
    end
  end
end
