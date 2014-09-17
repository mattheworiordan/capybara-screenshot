require 'spec_helper'

describe Capybara::Screenshot::RSpec do
  describe "used with RSpec" do
    include Aruba::Api

    before do
      clean_current_dir
    end

    def run_failing_case(code, error_message)
      gem_root = File.expand_path('../..', File.dirname(__FILE__))

      write_file('spec/test_failure.rb', <<-RUBY)
        %w(lib spec).each do |include_folder|
          $LOAD_PATH.unshift(File.join('#{gem_root}', include_folder))
        end
        require 'rspec'
        require 'capybara'
        require 'capybara/rspec'
        require 'capybara-screenshot'
        require 'capybara-screenshot/rspec'
        require 'support/test_app'

        Capybara.app = TestApp
        Capybara.save_and_open_page_path = 'tmp'
        Capybara::Screenshot.append_timestamp = false

        #{code}
      RUBY

      cmd = 'bundle exec rspec spec/test_failure.rb'
      run_simple cmd, false
      expect(output_from(cmd)).to include(error_message)
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
