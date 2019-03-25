require 'spec_helper'
require 'capybara-screenshot/s3_saver'

describe Capybara::Screenshot::S3Saver do
  let(:saver) { double('saver') }
  let(:bucket_name) { double('bucket_name') }
  let(:s3_object_configuration) { {} }
  let(:options) { {} }
  let(:s3_client) { double('s3_client') }
  let(:key_prefix){ "some/path/" }

  let(:s3_saver) { described_class.new(saver, s3_client, bucket_name, s3_object_configuration, options) }
  let(:s3_saver_with_key_prefix) { described_class.new(saver, s3_client, bucket_name, s3_object_configuration, key_prefix: key_prefix) }

  let(:region) { double('region') }

  before do
    allow(s3_client).to receive(:get_bucket_location).and_return(double(:bucket_location_response, location_constraint: region))
  end

  describe '.new_with_configuration' do
    let(:access_key_id) { double('access_key_id') }
    let(:secret_access_key) { double('secret_access_key') }
    let(:s3_client_credentials_using_defaults) {
      {
        access_key_id: access_key_id,
        secret_access_key: secret_access_key
      }
    }

    let(:s3_client_credentials) {
      s3_client_credentials_using_defaults.merge(region: region)
    }

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(described_class).to receive(:new)
    end

    it 'destructures the configuration into its components' do
      described_class.new_with_configuration(saver, {
        s3_client_credentials: s3_client_credentials,
        bucket_name: bucket_name
      }, s3_object_configuration)

      expect(Aws::S3::Client).to have_received(:new).with(s3_client_credentials)
      expect(described_class).to have_received(:new).with(saver, s3_client, bucket_name, s3_object_configuration, hash_including({}))
    end

    it 'passes key_prefix option if specified' do
      described_class.new_with_configuration(saver, {
        s3_client_credentials: s3_client_credentials,
        bucket_name: bucket_name,
        key_prefix: key_prefix,
      }, s3_object_configuration)

      expect(Aws::S3::Client).to have_received(:new).with(s3_client_credentials)
      expect(described_class).to have_received(:new).with(saver, s3_client, bucket_name, s3_object_configuration, hash_including(key_prefix: key_prefix))
    end

    it 'defaults the region to us-east-1' do
      default_region = 'us-east-1'

      described_class.new_with_configuration(saver, {
          s3_client_credentials: s3_client_credentials_using_defaults,
          bucket_name: bucket_name
      }, s3_object_configuration)

      expect(Aws::S3::Client).to have_received(:new).with(
        s3_client_credentials.merge(region: default_region)
      )

      expect(described_class).to have_received(:new).with(saver, s3_client, bucket_name, s3_object_configuration, hash_including({}))
    end

    it 'stores the object configuration when passed' do
      s3_object_configuration = { acl: 'public-read' }
      Capybara::Screenshot.s3_object_configuration = { acl: 'public-read' }

      described_class.new_with_configuration(saver, {
        s3_client_credentials: s3_client_credentials,
        bucket_name: bucket_name
      }, s3_object_configuration)

      expect(Aws::S3::Client).to have_received(:new).with(s3_client_credentials)
      expect(described_class).to have_received(:new).with(saver, s3_client, bucket_name, s3_object_configuration, hash_including({}))
    end

    it 'passes key_prefix option if specified' do
      described_class.new_with_configuration(saver, {
        s3_client_credentials: s3_client_credentials,
        bucket_name: bucket_name,
        key_prefix: key_prefix,
      }, s3_object_configuration)

      expect(Aws::S3::Client).to have_received(:new).with(s3_client_credentials)
      expect(described_class).to have_received(:new).with(saver, s3_client, bucket_name, s3_object_configuration, hash_including(key_prefix: key_prefix))
    end
  end

  describe '#save' do
    before do
      allow(saver).to receive(:html_saved?).and_return(false)
      allow(saver).to receive(:screenshot_saved?).and_return(false)
      allow(saver).to receive(:save)
    end

    context 'providing a bucket_host' do
      let(:options) { { bucket_host: 'some other location' } }
  
      it 'does not request the bucket location' do
        screenshot_path = '/baz/bim.jpg'

        screenshot_file = double('screenshot_file')

        expect(s3_saver).not_to receive(:determine_bucket_host)

        s3_saver.save
      end
    end

    it 'calls save on the underlying saver' do
      expect(saver).to receive(:save)

      s3_saver.save
    end

    it 'uploads the html' do
      html_path = '/foo/bar.html'
      expect(saver).to receive(:html_path).and_return(html_path)
      expect(saver).to receive(:html_saved?).and_return(true)

      html_file = double('html_file')

      expect(File).to receive(:open).with(html_path).and_yield(html_file)

      expect(s3_client).to receive(:put_object).with(
        bucket: bucket_name,
        key: 'bar.html',
        body: html_file
      )

      expect(s3_saver).to receive(:determine_bucket_host).and_call_original

      s3_saver.save
    end

    it 'uploads the screenshot' do
      screenshot_path = '/baz/bim.jpg'
      expect(saver).to receive(:screenshot_path).and_return(screenshot_path)
      expect(saver).to receive(:screenshot_saved?).and_return(true)

      screenshot_file = double('screenshot_file')

      expect(File).to receive(:open).with(screenshot_path).and_yield(screenshot_file)

      expect(s3_client).to receive(:put_object).with(
        bucket: bucket_name,
        key: 'bim.jpg',
        body: screenshot_file
      )

      s3_saver.save
    end

    context 'with object configuration' do
      let(:s3_object_configuration) { { acl: 'public-read' } }
      let(:s3_saver) { described_class.new(saver, s3_client, bucket_name, s3_object_configuration) }

      it 'uploads the html' do
        html_path = '/foo/bar.html'
        expect(saver).to receive(:html_path).and_return(html_path)
        expect(saver).to receive(:html_saved?).and_return(true)

        html_file = double('html_file')

        expect(File).to receive(:open).with(html_path).and_yield(html_file)

        expect(s3_client).to receive(:put_object).with(
          bucket: bucket_name,
          key: 'bar.html',
          body: html_file,
          acl: 'public-read'
        )

        s3_saver.save
      end

      it 'uploads the screenshot' do
        screenshot_path = '/baz/bim.jpg'
        expect(saver).to receive(:screenshot_path).and_return(screenshot_path)
        expect(saver).to receive(:screenshot_saved?).and_return(true)

        screenshot_file = double('screenshot_file')

        expect(File).to receive(:open).with(screenshot_path).and_yield(screenshot_file)

        expect(s3_client).to receive(:put_object).with(
          bucket: bucket_name,
          key: 'bim.jpg',
          body: screenshot_file,
          acl: 'public-read'
        )

        s3_saver.save
      end
    end

    context 'with key_prefix specified' do
      it 'uploads the html with key prefix' do
        html_path = '/foo/bar.html'
        expect(saver).to receive(:html_path).and_return(html_path)
        expect(saver).to receive(:html_saved?).and_return(true)

        html_file = double('html_file')

        expect(File).to receive(:open).with(html_path).and_yield(html_file)

        expect(s3_client).to receive(:put_object).with(
          bucket: bucket_name,
          key: 'some/path/bar.html',
          body: html_file
        )

        s3_saver_with_key_prefix.save
      end

      it 'uploads the screenshot with key prefix' do
        screenshot_path = '/baz/bim.jpg'
        expect(saver).to receive(:screenshot_path).and_return(screenshot_path)
        expect(saver).to receive(:screenshot_saved?).and_return(true)

        screenshot_file = double('screenshot_file')

        expect(File).to receive(:open).with(screenshot_path).and_yield(screenshot_file)

        expect(s3_client).to receive(:put_object).with(
          bucket: bucket_name,
          key: 'some/path/bim.jpg',
          body: screenshot_file
        )

        s3_saver_with_key_prefix.save
      end

      context 'with object configuration' do
        let(:s3_object_configuration) { { acl: 'public-read' } }

        it 'uploads the html' do
          html_path = '/foo/bar.html'
          expect(saver).to receive(:html_path).and_return(html_path)
          expect(saver).to receive(:html_saved?).and_return(true)

          html_file = double('html_file')

          expect(File).to receive(:open).with(html_path).and_yield(html_file)

          expect(s3_client).to receive(:put_object).with(
            bucket: bucket_name,
            key: 'some/path/bar.html',
            body: html_file,
            acl: 'public-read'
          )

          s3_saver_with_key_prefix.save
        end

        it 'uploads the screenshot' do
          screenshot_path = '/baz/bim.jpg'
          expect(saver).to receive(:screenshot_path).and_return(screenshot_path)
          expect(saver).to receive(:screenshot_saved?).and_return(true)

          screenshot_file = double('screenshot_file')

          expect(File).to receive(:open).with(screenshot_path).and_yield(screenshot_file)

          expect(s3_client).to receive(:put_object).with(
            bucket: bucket_name,
            key: 'some/path/bim.jpg',
            body: screenshot_file,
            acl: 'public-read'
          )

          s3_saver_with_key_prefix.save
        end
      end
    end
  end

  # Needed because we cannot depend on Verifying Doubles
  # in older RSpec versions
  describe 'an actual saver' do
    it 'implements the methods needed by the s3 saver' do
      instance_methods = Capybara::Screenshot::Saver.instance_methods

      expect(instance_methods).to include(:save)
      expect(instance_methods).to include(:html_saved?)
      expect(instance_methods).to include(:html_path)
      expect(instance_methods).to include(:screenshot_saved?)
      expect(instance_methods).to include(:screenshot_path)
    end
  end

  describe 'any other method' do
    it 'transparently passes through to the saver' do
      allow(saver).to receive(:foo_bar)

      args = double('args')
      s3_saver.foo_bar(*args)

      expect(saver).to have_received(:foo_bar).with(*args)
    end
  end
end
