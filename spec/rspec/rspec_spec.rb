require 'spec_helper'

describe Capybara::Screenshot::RSpec do
  describe '.after_failed_example' do
    context 'for a failed example in a feature that can be snapshotted' do
      before do
        allow(Capybara.page).to receive(:save_page)
        allow(Capybara.page).to receive(:current_url).and_return("http://test.local")
        allow(Capybara::Screenshot::Saver).to receive(:new).and_return(mock_saver)
      end
      let(:example) { double("example", exception: Exception.new, metadata: {}) }
      let(:mock_saver) do
        Capybara::Screenshot::Saver.new(Capybara, Capybara.page).tap do |saver|
          allow(saver).to receive(:save)
        end
      end

      it 'instantiates a saver and calls `save` on it' do
        expect(mock_saver).to receive(:save)
        described_class.after_failed_example(example)
      end

      it 'extends the metadata with an empty hash for screenshot metadata' do
        described_class.after_failed_example(example)
        expect(example.metadata).to have_key(:screenshot)
        expect(example.metadata[:screenshot]).to eql({})
      end

      context 'when a html file gets saved' do
        before { allow(mock_saver).to receive(:html_saved?).and_return(true) }

        it 'adds the html file path to the screenshot metadata' do
          described_class.after_failed_example(example)
          expect(example.metadata[:screenshot][:html]).to match("./screenshot")
        end
      end

      context 'when an image gets saved' do
        before { allow(mock_saver).to receive(:screenshot_saved?).and_return(true) }

        it 'adds the image path to the screenshot metadata' do
          described_class.after_failed_example(example)
          expect(example.metadata[:screenshot][:image]).to match("./screenshot")
        end
      end
    end
  end

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
