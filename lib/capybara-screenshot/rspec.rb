RSpec.configure do |config|
  # use the before hook to add an after hook that runs last
  config.before(:type => :request) do
    Capybara::Screenshot::RSpec.add_after(example.example_group) do
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
    class RSpec
      @@example_groups = []
      def self.add_after(example_group, &block)
        unless (@@example_groups & self_and_parents(example_group)).count > 0
          example_group.after :each, &block
          @@example_groups << example_group
        end
      end

      private
        # Return an array of current ExampleGroup and all parent ExampleGroups other than Core which has no metadata
        def self.self_and_parents(example_group, children = [])
          parent_is_core = example_group.superclass.metadata.nil? rescue true # don't ever raise an error if RSpec API changes in the future, lets rather do multiple screen shots as a side effect
          if parent_is_core
            children << example_group
            children
          else
            children << example_group
            self_and_parents(example_group.superclass, children)
          end
        end
    end
  end
end
