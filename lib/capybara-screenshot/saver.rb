require 'capybara-screenshot/helpers'

module Capybara
  module Screenshot
    class Saver
      attr_reader :capybara, :page, :file_base_name
      def initialize(capybara, page, html_save=true, filename_prefix='screenshot', upload_to_s3=nil)
        @capybara, @page, @html_save, @upload_to_s3 = capybara, page, html_save, upload_to_s3

        time_now = Time.now
        timestamp = "#{time_now.strftime('%Y-%m-%d-%H-%M-%S.')}#{'%03d' % (time_now.usec/1000).to_i}"

        filename = [filename_prefix]
        filename << timestamp if Capybara::Screenshot.append_timestamp
        filename << SecureRandom.hex if Capybara::Screenshot.append_random

        @file_base_name = filename.join('_')

        Capybara::Screenshot.prune
      end

      def save
        # if current_path empty then nothing to screen shot as browser has not loaded any URL
        return if capybara.current_path.to_s.empty?

        save_html if @html_save
        save_screenshot
      end

      def save_html
        path = html_path
        clear_save_and_open_page_path do
          if Capybara::VERSION.match(/^\d+/)[0] == '1'
            capybara.save_page(page.body, "#{path}")
          else
            capybara.save_page("#{path}")
          end
        end
        @html_saved = true
        upload_or_enqueue(path) if upload_to_s3?
      end

      def save_screenshot
        path = screenshot_path
        clear_save_and_open_page_path do
          result = Capybara::Screenshot.registered_drivers.fetch(capybara.current_driver) { |driver_name|
            warn "capybara-screenshot could not detect a screenshot driver for '#{capybara.current_driver}'. Saving with default with unknown results."
            Capybara::Screenshot.registered_drivers[:default]
          }.call(page.driver, path)
          if @screenshot_saved = result != :not_supported
            upload_or_enqueue(path) if upload_to_s3?
          end
        end
      end

      def html_location
        upload_to_s3? ? html_url : html_path
      end

      def html_path
        File.join(Capybara::Screenshot.capybara_root, "#{file_base_name}.html")
      end

      def html_url
        Capybara::Screenshot::S3.url_for(html_path)
      end

      def screenshot_location
        upload_to_s3? ? screenshot_url : screenshot_path
      end

      def screenshot_path
        File.join(Capybara::Screenshot.capybara_root, "#{file_base_name}.png")
      end

      def screenshot_url
        Capybara::Screenshot::S3.url_for(screenshot_path)
      end

      def html_saved?
        @html_saved
      end

      def screenshot_saved?
        @screenshot_saved
      end

      # If Capybara.save_and_open_page_path is set then
      # the html_path or screenshot_path can be appended to this path in
      # some versions of Capybara instead of using it as an absolute path
      def clear_save_and_open_page_path
        old_path = Capybara.save_and_open_page_path
        Capybara.save_and_open_page_path = nil
        yield
      ensure
        Capybara.save_and_open_page_path = old_path
      end

      def output_screenshot_path
        output "HTML screenshot: #{html_location}" if html_saved?
        output "Image screenshot: #{screenshot_location}" if screenshot_saved?
      end

      private
      def upload_to_s3?
        @upload_to_s3.nil? ? Capybara::Screenshot.upload_to_s3? : @upload_to_s3
      end

      def output(message)
        puts "    #{CapybaraScreenshot::Helpers.yellow(message)}"
      end

      def upload_or_enqueue(path)
        method = @upload_inline ? :upload : :enqueue
        Capybara::Screenshot::S3.send(method, path)
      end
    end
  end
end
