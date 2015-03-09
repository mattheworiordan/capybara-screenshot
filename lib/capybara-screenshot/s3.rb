require 'rubygems'
require 'aws-sdk-core'

module Capybara
  module Screenshot
    module S3
      class << self
        def configure(&block)
          @uploader = Uploader.new
          @uploader.instance_eval(&block)
          unless @uploader.bucket_name
            raise "Capybara::Screenshot::S3 - You must specify a bucket for S3 uploads"
          end
          Capybara::Screenshot.upload_to_s3 = true
          @paths_to_upload = []
        end

        def flush
          @paths_to_upload.each { |path| @uploader.upload(path) }
          @paths_to_upload = []
        end

        def enqueue(path)
          @paths_to_upload << path
        end

        def url_for(path)
          @uploader.url_for(path)
        end

        def upload(path)
          @uploader.upload(path)
        end

        class Uploader
          attr_writer :access_key_id
          attr_writer :bucket
          attr_writer :folder
          attr_writer :region
          attr_writer :secret_access_key

          def upload(path)
            key = File.basename(path)
            key = File.join(folder, key) if folder

            client.put_object(bucket: bucket, key: key, body: IO.read(path), acl: "public-read")
          end

          def bucket_name
            @bucket
          end

          def client
            @client ||= Aws::S3::Client.new(client_options)
          end

          def client_options
            options = { region: region }
            options[:credentials] = credentials if credentials
            options
          end

          def credentials
            @credentials ||= if @access_key_id && @secret_access_key
              Aws::Credentials.new(@access_key_id, @secret_access_key)
            end
          end

          def region
            @region || "us-east-1"
          end

          def bucket
            @s3_bucket ||= @bucket.respond_to?(:call) ? @bucket.call : @bucket
          end

          def folder
            @s3_folder ||= @folder.respond_to?(:call) ? @folder.call : @folder
          end

          def url_for(path)
            key = File.basename(path)
            key = File.join(folder, key) if folder
            "https://s3.amazonaws.com/#{bucket_name}/#{key}"
          end
        end
      end
    end
  end
end
