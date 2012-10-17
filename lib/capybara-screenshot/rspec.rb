RSpec.configure do |config|
  # use the before hook to add an after hook that runs last
  config.before(:type => :request) do
    Capybara::Screenshot::RSpecCache.add_after(example.example_group) do
      if Capybara::Screenshot.autosave_on_failure && example.exception
        filename_prefix = Capybara::Screenshot.filename_prefix_for(:rspec, example)

        saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
        saver.save

        example.metadata[:full_description] += "\n     Screenshot: #{saver.screenshot_path}"
      end
    end
  end
end

# keep a record of which example groups we've added an after hook to and add if one does not exist
module Capybara
  module Screenshot
    class RSpecCache
      @@example_groups = []
      def self.add_after(example_group, &block)
        unless @@example_groups.include?(example_group)
          example_group.after :each, &block
          @@example_groups << example_group
        end
      end
    end
  end
end