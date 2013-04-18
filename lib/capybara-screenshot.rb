module Capybara
  module Screenshot
    class << self
      attr_accessor :autosave_on_failure
      attr_accessor :registered_drivers
      attr_accessor :filename_prefix_formatters
      attr_accessor :append_screenshot_path
    end

    self.autosave_on_failure = true
    self.registered_drivers = {}
    self.filename_prefix_formatters = {}
    self.append_screenshot_path = true

    def self.screenshot_and_save_page
      saver = Saver.new(Capybara, Capybara.page)
      saver.save
      {:html => saver.html_path, :image => saver.screenshot_path}
    end

    def self.screenshot_and_open_image
      require "launchy"

      saver = Saver.new(Capybara, Capybara.page, false)
      saver.save
      Launchy.open saver.screenshot_path
      {:html => nil, :image => saver.screenshot_path}
    end

    class << self
      alias screen_shot_and_save_page screenshot_and_save_page
      alias screen_shot_and_open_image screenshot_and_open_image
    end

    def self.filename_prefix_for(test_type, test)
      filename_prefix_formatters.fetch(test_type) { |key|
        filename_prefix_formatters[:default]
      }.call(test)
    end

    def self.capybara_root
      return @capybara_root if defined?(@capybara_root)
      #If the path isn't set, default to the current directory
      capybara_tmp_path = Capybara.save_and_open_page_path || '.'

      @capybara = if defined?(::Rails)
        ::Rails.root.join capybara_tmp_path
      elsif defined?(Padrino)
        Padrino.root capybara_tmp_path
      elsif defined?(Sinatra)
        File.join(Sinatra::Application.root, capybara_tmp_path)
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
    if driver.respond_to?(:save_screenshot)
      driver.save_screenshot(path)
    else
      driver.render(path)
    end
  end

  register_driver(:webkit_debug) do |driver, path|
    driver.render(path)
  end

  register_driver(:terminus) do |driver, path|
    driver.save_screenshot(path) if driver.respond_to?(:save_screenshot)
  end
end

# Register filename prefix formatters
Capybara::Screenshot.class_eval do
  register_filename_prefix_formatter(:default) do |test|
    'screenshot'
  end
end

require 'capybara/dsl'
require 'capybara/util/save_and_open_page' if Capybara::VERSION.match(/^\d+/)[0] == '1' # no longer needed in Capybara version 2

require 'capybara-screenshot/saver'
require 'capybara-screenshot/capybara'


