module Capybara
  module Screenshot
    mattr_accessor :autosave_on_failure
    self.autosave_on_failure = true

    def self.screen_shot_and_save_page
      saver = Saver.new(Capybara, Capybara.body)
      saver.save
      {:html => saver.html_path, :image => saver.screenshot_path}
    end

    def self.screen_shot_and_open_image
      saver = Saver.new(Capybara, Capybara.body, false)
      saver.save
      Launchy.open saver.screenshot_path
      {:html => saver.html_path, :image => saver.screenshot_path}
    end

    def self.capybara_root
      return @capybara_root if defined?(@capybara_root)

      capybara_tmp_path = Capybara.save_and_open_page_path.to_s

      @capybara = if defined?(Rails)
        Rails.root.join capybara_tmp_path
      elsif defined?(Padrino)
        Padrino.root capybara_tmp_path
      elsif defined?(Sinatra)
        # Sinatra support, untested
        File.join(settings.root, capybara_tmp_path)
      else
        capybara_tmp_path
      end.to_s
    end
  end
end

require 'capybara-screenshot/saver'

# do nothing if Cucumber is not being used
if defined?(Cucumber::RbSupport::RbDsl)
  require 'capybara/cucumber'
  require 'capybara-screenshot/cucumber'
end

if defined?(RSpec)
  # capybara rspec must be included first so that this config.after is added to
  #   RSpec hooks afterwards, and thus executed first
  require 'capybara/rspec'
  require 'capybara-screenshot/rspec'
end

begin
  require 'minitest/unit'
  require 'capybara-screenshot/minitest'
rescue LoadError
  # mini test not available
end
