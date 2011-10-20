module Capybara
  module Screenshot
    module World
      def screen_shot_and_save_page
        require 'capybara/util/save_and_open_page'
        path = "/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}"
        Capybara.save_page body, "#{path}.html"
        if page.driver.respond_to?(:render)
          page.driver.render Rails.root.join "#{Capybara.save_and_open_page_path}" "#{path}.png"
        end
      end
    end
  end
end