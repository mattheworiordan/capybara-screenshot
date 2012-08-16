module Capybara
  module Screenshot
    class << self
      attr_accessor :autosave_on_failure
      attr_accessor :registered_drivers
      attr_accessor :filename_prefix_formatters
    end

    self.autosave_on_failure = true
    self.registered_drivers = {}
    self.filename_prefix_formatters = {}

    def self.screen_shot_and_save_page
      saver = Saver.new(Capybara, Capybara.page)
      saver.save
      {:html => saver.html_path, :image => saver.screenshot_path}
    end

    def self.screen_shot_and_open_image
      require "launchy"

      saver = Saver.new(Capybara, Capybara.page, false)
      saver.save
      Launchy.open saver.screenshot_path
      {:html => nil, :image => saver.screenshot_path}
    end

    def self.filename_prefix_for(test_type, test)
      filename_prefix_formatters.fetch(test_type) { |key|
        filename_prefix_formatters[:default]
      }.call(test)
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

    def self.register_driver(driver, &block)
      self.registered_drivers[driver] = block
    end

    def self.register_filename_prefix_formatter(test_type, &block)
      self.filename_prefix_formatters[test_type] = block
    end
  end
end

# Register driver renderers
Capybara::Screenshot.class_eval do
  register_driver(:default) do |driver, path|
    driver.render(path)
  end

  register_driver(:rack_test) do |driver, path|
    warn "Rack::Test capybara driver has no ability to output screen shots. Skipping."
  end

  register_driver(:selenium) do |driver, path|
    driver.browser.save_screenshot(path)
  end 

  register_driver(:poltergeist) do |driver, path|
    driver.render(path, :full => true)
  end 

  register_driver(:webkit) do |driver, path|
    driver.render(path)
  end 
end

# Register filename prefix formatters
Capybara::Screenshot.class_eval do
  register_filename_prefix_formatter(:default) do |test|
    'screenshot'
  end
end

require 'capybara/dsl'
require 'capybara-screenshot/saver'
require 'capybara-screenshot/capybara'
