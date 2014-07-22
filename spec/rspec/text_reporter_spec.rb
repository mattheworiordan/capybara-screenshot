require 'spec_helper'

describe Capybara::Screenshot::RSpec::TextReporter do
  before do
    # Mocking `RSpec::Core::Formatters::ProgressFormatter`, but only implementing the methods that
    # are actually used in `TextReporter#dump_failure_info_with_screenshot`.
    @reporter_class = Class.new do
      attr_reader :output

      def initialize
        @output = StringIO.new
      end

      protected

      def long_padding
        "  "
      end

      def failure_color(str)
        "colorized(#{str})"
      end

      private

      def dump_failure_info(example)
        output.puts "original failure info"
      end
    end

    @reporter = @reporter_class.new
    @reporter.singleton_class.send :include, described_class
  end

  context 'when there is no screenshot' do
    let(:example) { double("example", metadata: {}) }

    it 'doesnt change the original output of the reporter' do
      @reporter.dump_failure_info(example)
      @reporter.output.string.should == "original failure info\n"
    end
  end

  context 'when a html file was saved' do
    let(:example) { double("example", metadata: { screenshot: { html: "path/to/html" } }) }

    it 'appends the html file path to the original output' do
      @reporter.dump_failure_info(example)
      @reporter.output.string.should == "original failure info\n  #{"HTML screenshot: path/to/html".colorize(:yellow)}\n"
    end
  end

  context 'when a html file and an image were saved' do
    let(:example) { double("example", metadata: { screenshot: { html: "path/to/html", image: "path/to/image" } }) }

    it 'appends the image path to the original output' do
      @reporter.dump_failure_info(example)
      @reporter.output.string.should == "original failure info\n  #{"HTML screenshot: path/to/html".colorize(:yellow)}\n  #{"Image screenshot: path/to/image".colorize(:yellow)}\n"
    end
  end


  it 'works with older RSpec formatters where `#red` is used instead of `#failure_color`' do
    old_reporter_class = Class.new(@reporter_class) do
      undef_method :failure_color
      def red(str)
        "red(#{str})"
      end
    end
    old_reporter = old_reporter_class.new
    old_reporter.singleton_class.send :include, described_class
    example = double("example", metadata: { screenshot: { html: "path/to/html" } })
    old_reporter.dump_failure_info(example)
    old_reporter.output.string.should == "original failure info\n  #{"HTML screenshot: path/to/html".colorize(:yellow)}\n"
  end
end
