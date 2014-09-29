require 'spec_helper'

describe Capybara::Screenshot::RSpec do
  describe '.after_failed_example' do
    context 'for a failed example in a feature that can be snapshotted' do
      before do
        allow(Capybara.page).to receive(:save_page)
        allow(Capybara.page).to receive(:current_url).and_return("http://test.local")
        allow(Capybara::Screenshot::Saver).to receive(:new).and_return(mock_saver)
      end
      let(:example) { double("example", exception: Exception.new, metadata: {}) }
      let(:mock_saver) do
        Capybara::Screenshot::Saver.new(Capybara, Capybara.page).tap do |saver|
          allow(saver).to receive(:save)
        end
      end

      it 'instantiates a saver and calls `save` on it' do
        expect(mock_saver).to receive(:save)
        described_class.after_failed_example(example)
      end

      it 'extends the metadata with an empty hash for screenshot metadata' do
        described_class.after_failed_example(example)
        expect(example.metadata).to have_key(:screenshot)
        expect(example.metadata[:screenshot]).to eql({})
      end

      context 'when a html file gets saved' do
        before { allow(mock_saver).to receive(:html_saved?).and_return(true) }

        it 'adds the html file path to the screenshot metadata' do
          described_class.after_failed_example(example)
          expect(example.metadata[:screenshot][:html]).to match("./screenshot")
        end
      end

      context 'when an image gets saved' do
        before { allow(mock_saver).to receive(:screenshot_saved?).and_return(true) }

        it 'adds the image path to the screenshot metadata' do
          described_class.after_failed_example(example)
          expect(example.metadata[:screenshot][:image]).to match("./screenshot")
        end
      end

      context 'when prune strategy specified' do
        context 'for pruner strategy:' do
          [:keep_all, :keep_last_run, { keep: 3 }].each do |strategy|
            context strategy.to_s do
              it 'it calls Pruner with corresponding strategy' do
                Capybara::Screenshot.prune_strategy = strategy
                pruner = Capybara::Screenshot::Pruner

                pruner.should_receive(:new).with(strategy).and_call_original
                pruner.any_instance.should_receive(:prune_old_screenshots)
                described_class.after_failed_example(example)
              end
            end
          end
        end
      end
    end
  end
end
