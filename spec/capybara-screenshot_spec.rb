require 'spec_helper'

describe Capybara::Screenshot do
  describe ".register_driver" do
    before(:all) do
      @original_drivers = Capybara::Screenshot.registered_drivers.dup
    end

    after(:all) do
      Capybara::Screenshot.registered_drivers = @original_drivers
    end

    it 'should store driver with block' do
      block = lambda {}
      Capybara::Screenshot.register_driver :foo, &block

      Capybara::Screenshot.registered_drivers[:foo].should eq block
    end
  end

  describe ".register_filename_prefix_formatter" do
    before(:all) do
      @original_formatters = Capybara::Screenshot.filename_prefix_formatters.dup
    end

    after(:all) do
      Capybara::Screenshot.filename_prefix_formatters = @original_formatters
    end

    it 'should store test type with block' do
      block = lambda { |arg| }
      Capybara::Screenshot.register_filename_prefix_formatter :foo, &block

      Capybara::Screenshot.filename_prefix_formatters[:foo].should eq block
    end
  end

  describe ".filename_prefix_for" do
    it 'should return "screenshot" for undefined formatter' do
      Capybara::Screenshot.filename_prefix_for(:foo, double('test')).should eq 'screenshot'
    end
  end
end