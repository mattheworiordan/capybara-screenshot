require 'capybara-screenshot/rspec/base_reporter'

module Capybara
  module Screenshot
    module RSpec
      module JsonReporter
        extend BaseReporter

        enhance_with_screenshot :format_example

        def format_example_with_screenshot(example)
          format_example_without_screenshot(example).merge({
            screenshot: example.metadata[:screenshot]
          })
        end
      end
    end
  end
end
