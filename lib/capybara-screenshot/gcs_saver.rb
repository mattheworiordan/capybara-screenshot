require 'zlib'
require 'google/cloud/storage'

module Capybara
  module Screenshot
    class GcsSaver
      attr_accessor :html_path, :screenshot_path

      def initialize(saver, bucket, object_configuration, key_prefix)
        @saver = saver
        @bucket = bucket
        @key_prefix = key_prefix
        @object_configuration = object_configuration
      end

      def self.new_with_configuration(saver, configuration, object_configuration)
        conf = configuration.dup
        bucket_name = conf.delete(:bucket_name)
        key_prefix = conf.delete(:key_prefix)
        storage = Google::Cloud::Storage.new conf
        bucket = storage.bucket bucket_name, skip_lookup: true

        new(saver, bucket, object_configuration, key_prefix)
      rescue KeyError
        raise "Invalid GCS Configuration #{configuration}. Please refer to the documentation for the necessary configurations."
      end

      def save_and_upload_screenshot
        save_and do |type, local_file_path|
          if object_configuration.fetch(:content_encoding, '').to_sym.eql?(:gzip)
            compressed = StringIO.new ""
            gz = Zlib::GzipWriter.new(compressed, Zlib::BEST_COMPRESSION)
            gz.mtime = File.mtime(local_file_path)
            gz.orig_name = local_file_path
            gz.write IO.binread(local_file_path)
            gz.close
            data = StringIO.new compressed.string
          else
            data = local_file_path
          end
          gcs_upload_path = "#{@key_prefix}#{File.basename(local_file_path)}"
          f = bucket.create_file data, gcs_upload_path, object_configuration
          if f.acl.readers.include? 'allUsers'
            url = f.public_url
          else
            url = "https://storage.cloud.google.com/#{bucket.name}/#{gcs_upload_path}"
          end
          send("#{type}_path=", url)
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
                  :bucket,
                  :object_configuration
                  :key_prefix

      def save_and
        saver.save

        yield(:html, saver.html_path) if block_given? && saver.html_saved?
        yield(:screenshot, saver.screenshot_path) if block_given? && saver.screenshot_saved?
      end
    end
  end
end
