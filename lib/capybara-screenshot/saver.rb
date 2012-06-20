module Capybara
  module Screenshot
    class Saver
      attr_reader :capybara, :page, :file_base_name

      def initialize(capybara, page, html_save=true)
        @capybara, @page, @html_save = capybara, page, html_save
        @file_base_name = "screenshot-#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}"
      end

      def save
        # if current_path empty then nothing to screen shot as browser has not loaded any URL
        return if capybara.current_path.to_s.empty?

        save_html if @html_save
        save_screenshot
      end

      def save_html
        require 'capybara/util/save_and_open_page'
        capybara.save_page(page.body, "#{file_base_name}.html")
      end

      def save_screenshot
        if Capybara::Screenshot.registered_drivers.has_key?(capybara.current_driver)
          Capybara::Screenshot.registered_drivers[capybara.current_driver].call(page.driver, screenshot_path)
        else
          warn "capybara-screenshot could not detect a screenshot driver for '#{capybara.current_driver}'. Saving with default with unknown results."
          save_with_default
        end
      end

      def save_with_default
        page.driver.render(screenshot_path)
      end

      def html_path
        File.join(Capybara::Screenshot.capybara_root, "#{file_base_name}.html")
      end

      def screenshot_path
        File.join(Capybara::Screenshot.capybara_root, "#{file_base_name}.png")
      end

    end
  end
end
