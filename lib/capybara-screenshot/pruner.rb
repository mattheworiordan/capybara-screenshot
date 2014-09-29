module Capybara
  module Screenshot
    class Pruner
      def initialize(strategy)
        @keep = if [:keep_all, :keep_last_run].include?(strategy)
            strategy.to_s.gsub('keep_', '').to_sym
          elsif strategy.instance_of?(Hash) &&
                strategy[:keep].is_a?(Integer) &&
                strategy[:keep] > 0
            strategy[:keep]
          else
            fail 'Invalid prune strategy. Ex:' \
            'Capybara::Screenshot.prune_strategy = keep: 10'
          end
      end

      def prune_old_screenshots
        case @keep
        when :all
          # do nothing.
        when :last_run
        FileUtils.rm_rf(Dir.glob(Screenshot.capybara_root + '/*'))
        else
          unless Dir[Capybara::Screenshot.capybara_root].empty?
            prune_with_numeric_strategy(@keep)
          end
        end
      end

      def prune_with_numeric_strategy(count)
        total_files = Dir.entries(Capybara::Screenshot.capybara_root).
                      sort_by { |e| e }
        files_to_keep = total_files.last(count)

        files = (total_files - files_to_keep).map do |f|
          Capybara::Screenshot.capybara_root + '/' + f
        end

        # remove . and ..
        files.shift(2)
        FileUtils.rm_rf(files)
      end
    end
  end
end
