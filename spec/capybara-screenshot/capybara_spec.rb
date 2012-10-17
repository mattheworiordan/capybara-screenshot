require 'capybara/dsl'

module Capybara::Screenshot
	describe Capybara do

    it 'should add screen shot methods to the Capybara module' do
      ::Capybara.should respond_to(:screen_shot_and_save_page)
      ::Capybara.should respond_to(:screen_shot_and_open_image)
    end

    context 'request type example', :type => :request do
      it 'should have access to screen shot instance methods' do
        self.should respond_to(:screen_shot_and_save_page)
        self.should respond_to(:screen_shot_and_open_image)
      end
    end
	end
end
