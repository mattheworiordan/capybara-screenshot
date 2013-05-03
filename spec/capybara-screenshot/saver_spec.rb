require 'spec_helper'

describe Capybara::Screenshot::Saver do
  before(:all) do
    @original_drivers = Capybara::Screenshot.registered_drivers
    Capybara::Screenshot.registered_drivers[:default] = lambda {|driver, path| driver.render(path) }
  end

  after(:all) do
    Capybara::Screenshot.registered_drivers = @original_drivers
  end

  before do
    Capybara::Screenshot.stub(:capybara_root).and_return(capybara_root)
    Timecop.freeze(Time.local(2012, 6, 7, 8, 9, 10, 0))
  end

  let(:capybara_root) { '/tmp' }
  let(:timestamp) { '2012-06-07-08-09-10.000' }
  let(:file_basename) { "screenshot_#{timestamp}" }
  let(:screenshot_path) { "#{capybara_root}/#{file_basename}.png" }

  let(:driver_mock) { mock('Capybara driver').as_null_object }
  let(:page_mock) { mock('Capybara session page', :body => 'body', :driver => driver_mock).as_null_object }
  let(:capybara_mock) {
    mock(Capybara).as_null_object.tap do |m|
      m.stub(:current_driver).and_return(:default)
      m.stub(:current_path).and_return('/')
    end
  }

  let(:saver) { Capybara::Screenshot::Saver.new(capybara_mock, page_mock) }

  context 'html filename with Capybara Version 1' do
    before do
      stub_const("Capybara::VERSION", '1')
    end

    it 'should have default format of "screenshot_Y-M-D-H-M-S.ms.html"' do
      capybara_mock.should_receive(:save_page).with('body', File.join(capybara_root, "#{file_basename}.html"))

      saver.save
    end

    it 'should use name argument as prefix' do
      saver = Capybara::Screenshot::Saver.new(capybara_mock, page_mock, true, 'custom-prefix')

      capybara_mock.should_receive(:save_page).with('body', File.join(capybara_root, "custom-prefix_#{timestamp}.html"))

      saver.save
    end
  end

  context 'html filename with Capybara Version 2' do
    before do
      stub_const("Capybara::VERSION", '2')
    end

    it 'should have default format of "screenshot_Y-M-D-H-M-S.ms.html"' do
      capybara_mock.should_receive(:save_page).with(File.join(capybara_root, "#{file_basename}.html"))

      saver.save
    end

    it 'should use name argument as prefix' do
      saver = Capybara::Screenshot::Saver.new(capybara_mock, page_mock, true, 'custom-prefix')

      capybara_mock.should_receive(:save_page).with(File.join(capybara_root, "custom-prefix_#{timestamp}.html"))

      saver.save
    end
  end

  context 'screenshot image path' do
    it 'should be in capybara root output' do
      driver_mock.should_receive(:render).with(/^#{capybara_root}\//)

      saver.save
    end

    it 'should have default filename format of "screenshot_Y-M-D-H-M-S.ms.png"' do
      driver_mock.should_receive(:render).with(/#{file_basename}\.png$/)

      saver.save
    end

    it 'should use filename prefix argument as basename prefix' do
      saver = Capybara::Screenshot::Saver.new(capybara_mock, page_mock, true, 'custom-prefix')
      driver_mock.should_receive(:render).with(/#{capybara_root}\/custom-prefix_#{timestamp}\.png$/)

      saver.save
    end
  end

  it 'should not save html if false passed as html argument' do
    saver = Capybara::Screenshot::Saver.new(capybara_mock, page_mock, false)
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

    context 'has render method' do
      before do
        driver_mock.stub(:respond_to?).with(:'save_screenshot').and_return(false)
      end

      it 'should save driver render' do
        driver_mock.should_receive(:render).with(screenshot_path)

        saver.save
      end
    end

    context 'has save_screenshot method' do
      before do
        driver_mock.stub(:respond_to?).with(:'save_screenshot').and_return(true)
      end

      it 'should save driver render' do
        driver_mock.should_receive(:save_screenshot).with(screenshot_path)

        saver.save
      end
    end
  end

  describe "with webkit debug driver" do
    before do
      capybara_mock.stub(:current_driver).and_return(:webkit_debug)
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
      saver.should_receive(:warn).with(/screenshot driver for 'unknown'.*unknown results/).and_return(nil)

      saver.save
    end
  end
end
