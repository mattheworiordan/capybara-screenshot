require 'spec_helper'

describe Capybara::Screenshot do
  before(:all) do
    @original_drivers = Capybara::Screenshot.registered_drivers
  end

  after(:all) do
    Capybara::Screenshot.registered_drivers = @original_drivers
  end

  describe ".register_driver" do
    it 'should store driver with block' do
      block = lambda {}
      Capybara::Screenshot.register_driver :foo, &block

      Capybara::Screenshot.registered_drivers[:foo].should eq block
    end
  end
end