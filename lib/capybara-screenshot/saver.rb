module Capybara
  module Screenshot
    class Saver
      def self.screen_shot_and_save_page(capybara, body)
        unless capybara.current_path.blank?
          require 'capybara/util/save_and_open_page'
          path = "/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}"
          capybara.save_page body, "#{path}.html"
          if capybara.page.driver.respond_to?(:render)
            path = if defined?(Rails)
              Rails.root.join "#{capybara.save_and_open_page_path}#{path}.png"
            else
              # Sinatra support, untested
              File.join settings.root "#{capybara.save_and_open_page_path}#{path}.png"
            end
            capybara.page.driver.render path
          end
        end
      end
    end
  end
end