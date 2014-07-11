require 'spec_helper'

describe Capybara::Screenshot::RSpec do
  describe '.after_failed_example' do
    context 'for a failed example in a feature that can be snapshotted' do
      before do
        Capybara.page.stub(save_page: nil, current_url: "http://test.local")
        Capybara::Screenshot::Saver.stub(new: mock_saver)
      end
      let(:example) { double("example", exception: Exception.new, metadata: {}) }
      let(:mock_saver) { Capybara::Screenshot::Saver.new(Capybara, Capybara.page).tap { |saver| saver.stub(:save) } }

      it 'instantiates a saver and calls `save` on it' do
        mock_saver.should_receive(:save)
        described_class.after_failed_example(example)
      end

      it 'extends the metadata with an empty hash for screenshot metadata' do
        described_class.after_failed_example(example)
        example.metadata.should have_key(:screenshot)
        example.metadata[:screenshot].should == {}
      end

      context 'when a html file gets saved' do
        before { mock_saver.stub(:html_saved? => true) }

        it 'adds the html file path to the screenshot metadata' do
          described_class.after_failed_example(example)
          example.metadata[:screenshot][:html].should start_with("./screenshot")
        end
      end

      context 'when an image gets saved' do
        before { mock_saver.stub(:screenshot_saved? => true) }

        it 'adds the image path to the screenshot metadata' do
          described_class.after_failed_example(example)
          example.metadata[:screenshot][:image].should start_with("./screenshot")
        end
      end
    end
  end
end
