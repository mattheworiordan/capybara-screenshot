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

          colorize = lambda { |str| respond_to?(:failure_color, true) ? failure_color(str) : red(str) }
          output.puts(long_padding + colorize["HTML page: #{screenshot[:html]}"]) if screenshot[:html]
          output.puts(long_padding + colorize["Screenshot: #{screenshot[:image]}"]) if screenshot[:image]
        end
      end
    end
  end
end
