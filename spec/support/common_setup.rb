module CommonSetup
  def self.included(target)
    target.let(:gem_root) { File.expand_path('../..', File.dirname(__FILE__)) }

    target.let(:ensure_load_paths_valid) do
      <<-RUBY
        %w(lib spec).each do |include_folder|
          $LOAD_PATH.unshift(File.join('#{gem_root}', include_folder))
        end
      RUBY
    end

    target.let(:setup_test_app) do
      <<-RUBY
        require 'support/test_app'
        Capybara.save_and_open_page_path = 'tmp'
        Capybara.app = TestApp
        Capybara::Screenshot.append_timestamp = false
      RUBY
    end

    target.before do
      if ENV['BUNDLE_GEMFILE'] && ENV['BUNDLE_GEMFILE'].match(/^\.|^[^\/\.]/)
        ENV['BUNDLE_GEMFILE'] = File.join(gem_root, ENV['BUNDLE_GEMFILE'])
      end
    end
  end
end
