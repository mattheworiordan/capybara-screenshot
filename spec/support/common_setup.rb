module CommonSetup
  def self.included(target)
    target.class_eval do
      include Aruba::Api
    end

    target.let(:gem_root) { File.expand_path('../..', File.dirname(__FILE__)) }

    target.let(:ensure_load_paths_valid) do
      <<-RUBY
        %w(lib spec).each do |include_folder|
          $LOAD_PATH.unshift(File.join('#{gem_root}', include_folder))
        end
      RUBY
    end

    target.let(:screenshot_path) { 'tmp' }
    target.let(:screenshot_for_pruning_path) { "#{screenshot_path}/old_screenshot.html" }

    target.let(:setup_test_app) do
      <<-RUBY
        require 'support/test_app'
        Capybara::Screenshot.capybara_tmp_path = '#{screenshot_path}'
        Capybara.app = TestApp
        Capybara::Screenshot.append_timestamp = false
        #{@additional_setup_steps}
      RUBY
    end

    target.before do
      if ENV['BUNDLE_GEMFILE'] && ENV['BUNDLE_GEMFILE'].match(/^\.|^[^\/\.]/)
        ENV['BUNDLE_GEMFILE'] = File.join(gem_root, ENV['BUNDLE_GEMFILE'])
      end
    end

    target.after(:each) do |example|
      if example.exception
        puts "Output from failed Aruba test:"
        puts all_commands.map { |c| c.output }.map { |line| "   #{line}"}
        puts ""
      end
    end

    def run_simple_with_retry(cmd, fail_on_error: false)
      run_command_and_stop(cmd, fail_on_error: fail_on_error)
    rescue ChildProcess::TimeoutError => e
      puts "run_command_and_stop(#{cmd}, fail_on_error: #{fail_on_error}) failed. Will retry once. `#{e.message}`"
      run_command_and_stop(cmd, fail_on_error: fail_on_error)
    end

    def configure_prune_strategy(strategy)
       @additional_setup_steps = "Capybara::Screenshot.prune_strategy = :keep_last_run"
    end

    def create_screenshot_for_pruning
      write_file screenshot_for_pruning_path, '<html></html>'
    end

    def assert_screenshot_pruned
      expect(screenshot_for_pruning_path).to_not be_an_existing_file
    end

    def assert_screenshot_not_pruned
      expect(screenshot_for_pruning_path).to be_an_existing_file
    end
  end
end
