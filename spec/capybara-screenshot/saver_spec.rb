require 'spec_helper'

describe Capybara::Screenshot::Saver do
  before do
    Capybara::Screenshot.stub(:capybara_root).and_return(capybara_root)
    Timecop.freeze(Time.local(2012, 6, 7, 8, 9, 10))
  end

  let(:capybara_root) { '/tmp' }
  let(:file_basename) { "screenshot-2012-06-07-08-09-10" }
  let(:screenshot_path) { "#{capybara_root}/#{file_basename}.png" }
  
  let(:body_mock) { mock(String) }
  let(:driver_mock) { mock('Capybara driver').as_null_object }
  let(:capybara_mock) { 
    mock(Capybara).as_null_object.tap do |m|
      m.stub(:current_driver).and_return(:default)
      m.stub(:current_path).and_return('/')
      m.stub_chain(:page, :driver).and_return(driver_mock)
    end
  }

  let(:saver) { Capybara::Screenshot::Saver.new(capybara_mock, body_mock) }

  it 'should save html file with "screenshot-Y-M-D-H-M-S.html" format' do
    capybara_mock.should_receive(:save_page).with(body_mock, "#{file_basename}.html")
    
    saver.save
  end

  it 'should save screenshot file in capybara root output directory with format "screenshot-Y-M-D-H-M-S.png"' do
    driver_mock.should_receive(:render).with(screenshot_path)

    saver.save
  end

  it 'should not save html if false passed as html argument' do
    saver = Capybara::Screenshot::Saver.new(capybara_mock, body_mock, false)
    capybara_mock.should_not_receive(:save_page)

    saver.save
  end

  it 'should save if current_path is empty' do
    capybara_mock.stub(:current_path).and_return(nil)
    capybara_mock.should_not_receive(:save_page)
    driver_mock.should_not_receive(:render)

    saver.save 
  end

  describe "with selenium driver" do
    before do
      capybara_mock.stub(:current_driver).and_return(:selenium)
    end

    it 'should save via browser' do
      browser_mock = mock('browser')
      driver_mock.should_receive(:browser).and_return(browser_mock)
      browser_mock.should_receive(:save_screenshot).with(screenshot_path)

      saver.save 
    end
  end

  describe "with poltergeist driver" do
    before do
      capybara_mock.stub(:current_driver).and_return(:poltergeist)
    end

    it 'should save driver render with :full => true' do
      driver_mock.should_receive(:render).with(screenshot_path, {:full => true})

      saver.save 
    end
  end

  describe "with webkit driver" do
    before do
      capybara_mock.stub(:current_driver).and_return(:webkit)
    end

    it 'should save driver render' do
      driver_mock.should_receive(:render).with(screenshot_path)

      saver.save 
    end
  end

  describe "with unknown driver" do
    before do
      capybara_mock.stub(:current_driver).and_return(:unknown)
      saver.stub(:warn).and_return(nil)
    end

    it 'should save driver render' do
      driver_mock.should_receive(:render).with(screenshot_path)

      saver.save 
    end

    it 'should output warning about unknown results' do
      # Not pure mock testing 
      saver.should_receive(:warn).with(/driver 'unknown'.*unknown results/).and_return(nil)

      saver.save 
    end
  end
end