require 'spec_helper'
require 'capybara-screenshot/gcs_saver'

describe Capybara::Screenshot::GcsSaver do
  let(:saver) { double('saver') }
  let(:credentials) { double('credentials') }
  let(:bucket_name) { double('bucket_name') }
  let(:bucket) { double('bucket') }
  let(:gcs_object_configuration) { {} }
  let(:gcs_client) { double('gcs_client') }
  let(:key_prefix) { 'some/path/' }
  let(:gcs_file) { double('gcs_file') }

  let(:gcs_saver) { described_class.new(saver, bucket, gcs_object_configuration, nil) }
  let(:gcs_saver_with_key_prefix) { described_class.new(saver, bucket, gcs_object_configuration, key_prefix) }

  before do
    allow(gcs_client).to receive(:bucket).and_return(bucket)
    allow(bucket).to receive(:create_file).and_return(gcs_file)
    allow(bucket).to receive(:name).and_return(bucket_name)
    allow(gcs_file).to receive_message_chain(:acl, :readers, :include?).with('allUsers').and_return(false)
  end

  describe '.new_with_configuration' do
    before do
      allow(Google::Cloud::Storage).to receive(:new).and_return(gcs_client)
      allow(described_class).to receive(:new)
    end

    it 'destructures the configuration into its components' do
      described_class.new_with_configuration(saver, {
        bucket_name: bucket_name
      }, gcs_object_configuration)

      expect(Google::Cloud::Storage).to have_received(:new).with({})
      expect(described_class).to have_received(:new).with(saver, bucket, gcs_object_configuration, nil)
    end

    it 'passes key_prefix option if specified' do
      described_class.new_with_configuration(saver, {
        credentials: credentials,
        bucket_name: bucket_name,
        key_prefix: key_prefix,
      }, gcs_object_configuration)

      expect(Google::Cloud::Storage).to have_received(:new).with(credentials: credentials)
      expect(described_class).to have_received(:new).with(saver, bucket, gcs_object_configuration, key_prefix)
    end

    it 'stores the object configuration when passed' do
      gcs_object_configuration = { acl: 'public-read' }
      Capybara::Screenshot.gcs_object_configuration = { acl: 'public-read' }

      described_class.new_with_configuration(saver, {
        credentials: credentials,
        bucket_name: bucket_name
      }, gcs_object_configuration)

      expect(Google::Cloud::Storage).to have_received(:new).with(credentials: credentials)
      expect(described_class).to have_received(:new).with(saver, bucket, gcs_object_configuration, nil)
    end
  end

  describe '#save' do
    before do
      allow(saver).to receive(:html_saved?).and_return(false)
      allow(saver).to receive(:screenshot_saved?).and_return(false)
      allow(saver).to receive(:save)
    end

    it 'calls save on the underlying saver' do
      expect(saver).to receive(:save)

      gcs_saver.save
    end

    it 'uploads the html' do
      html_path = '/foo/bar.html'
      expect(saver).to receive(:html_path).and_return(html_path)
      expect(saver).to receive(:html_saved?).and_return(true)

      expect(bucket).to receive(:create_file).with(
        html_path,
        File.basename(html_path),
        {}
      )

      gcs_saver.save
    end

    it 'uploads the screenshot' do
      screenshot_path = '/baz/bim.jpg'
      expect(saver).to receive(:screenshot_path).and_return(screenshot_path)
      expect(saver).to receive(:screenshot_saved?).and_return(true)

      expect(bucket).to receive(:create_file).with(
        screenshot_path,
        File.basename(screenshot_path),
        {}
      )

      gcs_saver.save
    end

    context 'with object configuration' do
      let(:gcs_object_configuration) { { acl: 'public_read' } }
      let(:gcs_saver) { described_class.new(saver, bucket, gcs_object_configuration, nil) }
      let(:public_url) { double('public_url') }

      before do
        allow(gcs_file).to receive_message_chain(:acl, :readers, :include?).with('allUsers').and_return(true)
        allow(gcs_file).to receive(:public_url).and_return(public_url)
      end

      it 'uploads the html' do
        html_path = '/foo/bar.html'
        expect(saver).to receive(:html_path).and_return(html_path)
        expect(saver).to receive(:html_saved?).and_return(true)
        expect(gcs_saver).to receive(:html_path=).with(public_url)

        expect(bucket).to receive(:create_file).with(
          html_path,
          File.basename(html_path),
          acl: 'public_read'
        )

        gcs_saver.save
      end

      it 'uploads the screenshot' do
        screenshot_path = '/baz/bim.jpg'
        expect(saver).to receive(:screenshot_path).and_return(screenshot_path)
        expect(saver).to receive(:screenshot_saved?).and_return(true)
        expect(gcs_saver).to receive(:screenshot_path=).with(public_url)

        expect(bucket).to receive(:create_file).with(
          screenshot_path,
          File.basename(screenshot_path),
          acl: 'public_read'
        )

        gcs_saver.save
      end
    end

    context 'with key_prefix specified' do
      it 'uploads the html with key prefix' do
        html_path = '/foo/bar.html'
        expect(saver).to receive(:html_path).and_return(html_path)
        expect(saver).to receive(:html_saved?).and_return(true)

        expect(bucket).to receive(:create_file).with(
          html_path,
          'some/path/' + File.basename(html_path),
          {}
        )

        gcs_saver_with_key_prefix.save
      end

      it 'uploads the screenshot with key prefix' do
        screenshot_path = '/baz/bim.jpg'
        expect(saver).to receive(:screenshot_path).and_return(screenshot_path)
        expect(saver).to receive(:screenshot_saved?).and_return(true)

        expect(bucket).to receive(:create_file).with(
          screenshot_path,
          'some/path/' + File.basename(screenshot_path),
          {}
        )

        gcs_saver_with_key_prefix.save
      end

      context 'with gzip' do
        let(:gcs_object_configuration) { { content_encoding: 'gzip' } }

        it 'uploads the html' do
          html_path = '/foo/bar.html'
          expect(saver).to receive(:html_path).and_return(html_path)
          expect(saver).to receive(:html_saved?).and_return(true)

          html_file = double('html_file')

          expect(File).to receive(:mtime).with(html_path).and_return(Time.now)
          expect(IO).to receive(:binread).with(html_path).and_return(html_file)

          expect(bucket).to receive(:create_file).with(
            instance_of(StringIO),
            'some/path/' + File.basename(html_path),
            content_encoding: 'gzip'
          )

          gcs_saver_with_key_prefix.save
        end
      end
    end
  end
end
