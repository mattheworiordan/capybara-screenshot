require 'capybara-screenshot/rspec/base_reporter'
require 'base64'
require 'uri'

module Capybara
  module Screenshot
    module RSpec
      module HtmlEmbedReporter
        extend BaseReporter
        enhance_with_screenshot :extra_failure_content

        def extra_failure_content_with_screenshot(exception)
          result  = extra_failure_content_without_screenshot(exception)
          example = @failed_examples.last
          # Ignores saved html file, only saved image will be embedded (if present)
          if (screenshot = example.metadata[:screenshot]) && screenshot[:image]
            result += "<img src='#{image_tag_source(screenshot[:image])}' style='display: block'>"
          end
          result
        end

        private

        def image_tag_source(path)
          if URI.regexp(%w[http https]) =~ path
            path
          else
            image = File.binread(path)
            encoded_img = Base64.encode64(image)
            "data:image/png;base64,#{encoded_img}"
          end
        end
      end
    end
  end
end
