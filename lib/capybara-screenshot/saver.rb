module Capybara
  module Screenshot
    module Saver
      def self.screen_shot_and_save_page(capybara, body)
        #Our default return values
        html_path = nil
        image_path = nil

        # if current_path empty then nothing to screen shot as browser has not loaded any URL
        unless capybara.current_path.to_s.empty?
          require 'capybara/util/save_and_open_page'
          file_base_name = "#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}"
          #will save to the capybara.save_and_open_page_path
          html_path = "{capybara.save_and_open_page_path}#{file_base_name}.html"
          capybara.save_page(body, "#{file_base_name}.html")

          #where should we save the screenshot to
          if defined?(Rails)
            screenshot_path = Rails.root.join "#{capybara.save_and_open_page_path}/#{file_base_name}.png"
          elsif defined?(Sinatra) and !defined?(Padrino) # settings will be nil for Padrino apps
            # Sinatra support, untested
            screenshot_path = File.join(settings.root, "#{capybara.save_and_open_page_path}/#{file_base_name}.png")
          else
            screenshot_path = File.join(capybara.save_and_open_page_path.to_s, "#{file_base_name}.png")
          end

          #We try to figure out how to call the screenshot method on the current driver
          case capybara.current_driver
          when :poltergeist
            capybara.page.driver.render(screenshot_path, :full => true)
          when :selenium
            capybara.page.driver.browser.save_screenshot(screenshot_path)
          else
            #For other drivers that support a plain .render call and only expect the path as a parameter
            #This includes e.g. capybara-webkit
            if capybara.page.driver.respond_to?(:render)
              capybara.page.driver.render(screenshot_path)
            end
          end
        end
        #we return the path to the html and the screenshot
        {:html => html_path, :image => screenshot_path}
      end
    end
  end
end

