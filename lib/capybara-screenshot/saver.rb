module Capybara
  module Screenshot
    module Saver
      def self.screen_shot_and_save_page(capybara, body)        
        if capybara.current_path.to_s.empty?
          puts "Current path is empty, can't take a screenshot"
        else
          puts "Trying to take a screenshot for #{capybara.current_path}."
          require 'capybara/util/save_and_open_page'
          file_base_name = "#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}"
          #will save to the capybara.save_and_open_page_path
          html_path = "{capybara.save_and_open_page_path}#{file_base_name}.html"
          capybara.save_page(body, "#{file_base_name}.html")
          
          #where should we save the screenshot to
          if defined?(Rails)
            screenshot_path = Rails.root.join "#{capybara.save_and_open_page_path}/#{file_base_name}.png"
          elsif defined?(Sinatra)
            # Sinatra support, untested
            screenshot_path = File.join(settings.root, "#{capybara.save_and_open_page_path}/#{file_base_name}.png")
          else
            #screenshot_path = File.join(capybara.save_and_open_page_path.to_s, "#{file_base_name}.png")
            screenshot_path = "#{file_base_name}.png"
          end
          
          puts "Saving the screenshot as #{screenshot_path}."
            
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
            else
              puts "Driver unknown and doesn't respond to :render, can't capture screenshots: #{capybara.current_driver}"
            end
          end
        end
        #we return the path to the html and the screenshot
        {:html => html_path, :image => screenshot_path}
      end
    end
  end
end

