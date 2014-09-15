require 'spec_helper'

describe Capybara::Screenshot::RSpec do
  describe '.after_failed_example' do
    context 'for a failed example in a feature that can be snapshotted' do
      before do
        Capybara.page.stub(save_page: nil, current_url: "http://test.local")
        Capybara::Screenshot::Saver.stub(new: mock_saver)
      end
      let(:example) { double("example", exception: Exception.new, metadata: {}) }
      let(:mock_saver) { Capybara::Screenshot::Saver.new(Capybara, Capybara.page).tap { |saver| saver.stub(:save) } }

      it 'instantiates a saver and calls `save` on it' do
        mock_saver.should_receive(:save)
        described_class.after_failed_example(example)
      end

      it 'extends the metadata with an empty hash for screenshot metadata' do
        described_class.after_failed_example(example)
        example.metadata.should have_key(:screenshot)
        example.metadata[:screenshot].should == {}
      end

      context 'when a html file gets saved' do
        before { mock_saver.stub(:html_saved? => true) }

        it 'adds the html file path to the screenshot metadata' do
          described_class.after_failed_example(example)
          example.metadata[:screenshot][:html].should match("./screenshot")
        end
      end

      context 'when an image gets saved' do
        before { mock_saver.stub(:screenshot_saved? => true) }

        it 'adds the image path to the screenshot metadata' do
          described_class.after_failed_example(example)
          example.metadata[:screenshot][:image].should match("./screenshot")
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
