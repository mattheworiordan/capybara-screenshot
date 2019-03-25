require 'aws-sdk-s3'

module Capybara
  module Screenshot
    class S3Saver
      DEFAULT_REGION = 'us-east-1'

      attr_accessor :html_path, :screenshot_path

      def initialize(saver, s3_client, bucket_name, object_configuration, options={})
        @saver = saver
        @s3_client = s3_client
        @bucket_name = bucket_name
        @bucket_host = options[:bucket_host]
        @key_prefix = options[:key_prefix]
        @object_configuration = object_configuration
      end

      def self.new_with_configuration(saver, configuration, object_configuration)
        default_s3_client_credentials = {
          region: DEFAULT_REGION
        }

        s3_client_credentials = default_s3_client_credentials.merge(
          configuration.fetch(:s3_client_credentials)
        )

        s3_client = Aws::S3::Client.new(s3_client_credentials)
        bucket_name = configuration.fetch(:bucket_name)

        new(saver, s3_client, bucket_name, object_configuration, configuration)
      rescue KeyError
        raise "Invalid S3 Configuration #{configuration}. Please refer to the documentation for the necessary configurations."
      end

      def save_and_upload_screenshot
        save_and do |type, local_file_path|
          File.open(local_file_path) do |file|
            s3_upload_path = "#{@key_prefix}#{File.basename(local_file_path)}"

            object_payload = {
              bucket: bucket_name,
              key: s3_upload_path,
              body: file
            }

            object_payload.merge!(object_configuration) unless object_configuration.empty?

            s3_client.put_object(
                object_payload
            )

            host = bucket_host || determine_bucket_host

            send("#{type}_path=", "https://#{host}/#{s3_upload_path}")
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
                  :bucket_name,
                  :bucket_host,
                  :object_configuration
                  :key_prefix

      ##
      # Reads the bucket location using a S3 get_bucket_location request.
      # Requires the +s3:GetBucketLocation+ policy.
      def determine_bucket_host
        s3_region = s3_client.get_bucket_location(bucket: bucket_name).location_constraint
        "#{bucket_name}.s3-#{s3_region}.amazonaws.com"
      end

      def save_and
        saver.save

        yield(:html, saver.html_path) if block_given? && saver.html_saved?
        yield(:screenshot, saver.screenshot_path) if block_given? && saver.screenshot_saved?
      end
    end
  end
end
