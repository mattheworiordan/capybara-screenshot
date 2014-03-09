require 'spec_helper'

describe Capybara::Screenshot::RSpec do
  describe '.after_failed_example' do
    context 'for a failed example in a feature that can be snapshotted' do
      before do 
        Capybara.page.stub(save_page: nil, current_url: "http://test.local")
        Capybara::Screenshot::Saver.stub(new: mock_saver)
      end
      let(:example){ double("example", exception: Exception.new, metadata: {full_description: "full desc"}) }
      let(:mock_saver){ Capybara::Screenshot::Saver.new(Capybara, Capybara.page).tap{ |saver| saver.stub(:save) } }
    
      it 'instantiates a saver and calls `save` on it' do
        mock_saver.should_receive(:save)
        described_class.after_failed_example(example)
      end
    
      it 'does not alter the full description by default' do
        described_class.after_failed_example(example)
        example.metadata[:full_description].should == "full desc"
      end
    
      context 'when a html file gets saved' do
        before { mock_saver.stub(:html_saved? => true) }
      
        it 'appends the html file’s path to the full description' do
          described_class.after_failed_example(example)
          example.metadata[:full_description].should start_with("full desc\n     HTML page: ./screenshot")
        end
      end

      context 'when an image gets saved' do
        before { mock_saver.stub(:screenshot_saved? => true) }
      
        it 'appends the image’s path to the full description' do
          described_class.after_failed_example(example)
          example.metadata[:full_description].should start_with("full desc\n     Screenshot: ./screenshot")
        end
      end
    end
  end
end