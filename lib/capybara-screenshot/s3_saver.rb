require 'aws-sdk'

module Capybara
  module Screenshot
    class S3Saver
      DEFAULT_REGION = 'us-east-1'

      def initialize(saver, s3_client, bucket_name)
        @saver = saver
        @s3_client = s3_client
        @bucket_name = bucket_name
      end

      def self.new_with_configuration(saver, configuration)
        default_s3_client_credentials = {
          region: DEFAULT_REGION
        }

        s3_client_credentials = default_s3_client_credentials.merge(
          configuration.fetch(:s3_client_credentials)
        )

        s3_client = Aws::S3::Client.new(s3_client_credentials)
        bucket_name = configuration.fetch(:bucket_name)

        new(saver, s3_client, bucket_name)
      rescue KeyError
        raise "Invalid S3 Configuration #{configuration}. Please refer to the documentation for the necessary configurations."
      end

      def save_and_upload_screenshot
        save_and do |local_file_path|
          File.open(local_file_path) do |file|
            s3_client.put_object(
                bucket: bucket_name,
                key: File.basename(local_file_path),
                body: file
            )
          end
        end
      end
      alias_method :save, :save_and_upload_screenshot

      def method_missing(method, *args)
        # Need to use @saver instead of S3Saver#saver attr_reader method because
        # using the method goes into infinite loop. Maybe attr_reader implements
        # its methods via method_missing?
        @saver.send(method, *args)
      end

      private
      attr_reader :saver,
                  :s3_client,
                  :bucket_name

      def save_and
        saver.save

        yield(saver.html_path) if block_given? && saver.html_saved?
        yield(saver.screenshot_path) if block_given? && saver.screenshot_saved?
      end
    end
  end
end
