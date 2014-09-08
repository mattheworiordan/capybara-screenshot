require 'capybara-screenshot/rspec/base_reporter'

module Capybara
  module Screenshot
    module RSpec
      module TextReporter
        extend BaseReporter
        enhance_with_screenshot :dump_failure_info

        def dump_failure_info_with_screenshot(example)
          dump_failure_info_without_screenshot(example)
          return unless (screenshot = example.metadata[:screenshot])

          output.puts(long_padding + "HTML screenshot: #{screenshot[:html]}".yellow) if screenshot[:html]
          output.puts(long_padding + "Image screenshot: #{screenshot[:image]}".yellow) if screenshot[:image]
        end
      end
    end
  end
end
