module Capybara
  module Screenshot
    class Saver
      attr_reader :capybara, :page, :file_base_name

      def initialize(capybara, page, html_save=true, filename_prefix='screenshot')
        @capybara, @page, @html_save = capybara, page, html_save
        time_now = Time.now
        @file_base_name = "#{filename_prefix}_#{time_now.strftime('%Y-%m-%d-%H-%M-%S.')}#{'%03d' % (time_now.usec/1000).to_i}"
      end

      def save
        # if current_path empty then nothing to screen shot as browser has not loaded any URL
        return if capybara.current_path.to_s.empty?

        save_html if @html_save
        save_screenshot
      end

      def save_html
        if Capybara::VERSION.match(/^\d+/)[0] == '1'
          capybara.save_page(page.body, "#{html_path}")
        else
          capybara.save_page("#{html_path}")
        end
        warn "Saved file #{html_path}"
      end

      def save_screenshot
        Capybara::Screenshot.registered_drivers.fetch(capybara.current_driver) { |driver_name|
          warn "capybara-screenshot could not detect a screenshot driver for '#{capybara.current_driver}'. Saving with default with unknown results."
          Capybara::Screenshot.registered_drivers[:default]
        }.call(page.driver, screenshot_path)
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
