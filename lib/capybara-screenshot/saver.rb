require 'capybara/util/save_and_open_page'

module Capybara
  module Screenshot
    class Saver
      def self.screen_shot_and_save_page(capybara, body)
        saver = new(capybara, body)
        saver.save
        {:html => saver.html_path, :image => saver.screenshot_path}
      end

      attr_reader :capybara, :body, :file_base_name

      def initialize(capybara, body, html_save=true)
        @capybara, @body, @html_save = capybara, body, html_save
        @file_base_name = "#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}"
      end

      def save
        # if current_path empty then nothing to screen shot as browser has not loaded any URL
        return {} if capybara.current_path.to_s.empty?

        save_html if @html_save
        save_screenshot
      end

      def save_html
        capybara.save_page(body, html_path)
      end

      def save_screenshot
        driver_save_method = :"save_with_#{capybara.current_driver}"
        if respond_to?(driver_save_method)
          send(driver_save_method)
        else
          warn "capybara-screenshot could not detect a save method for driver '#{capybara.current_driver}'. Saving with default with unknown results."
          save_with_default
        end
      end

      def save_with_selenium
        capybara.page.driver.browser.save_screenshot(screenshot_path)
      end

      def save_with_poltergeist
        capybara.page.driver.render(screenshot_path, :full => true)
      end

      def save_with_default
        capybara.page.driver.render(screenshot_path)
      end
      alias_method :save_with_webkit, :save_with_default

      def html_path
        "#{capybara.save_and_open_page_path}#{file_base_name}.html"
      end

      def screenshot_path
        capybara_root = capybara.save_and_open_page_path

        if defined?(Rails)
          Rails.root.join "#{capybara_root}/#{file_base_name}.png"
        elsif defined?(Padrino)
          Padrino.root "#{capybara_root}/#{file_base_name}.png"
        elsif defined?(Sinatra)
          # Sinatra support, untested
          File.join(settings.root, "#{capybara_root}/#{file_base_name}.png")
        else
          File.join(capybara_root.to_s, "#{file_base_name}.png")
        end.to_s
      end

    end
  end
end
