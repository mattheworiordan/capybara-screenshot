require 'spec_helper'

describe Capybara::Screenshot::Pruner do
  describe '#initialize' do
    context 'should accept generic strategies:' do
      [:keep_all, :keep_last_run].each do |strategy|
        it ":#{strategy}" do
          pruner = Capybara::Screenshot::Pruner.new(strategy)
          expected_value = strategy.to_s.gsub('keep_', '').to_sym
          expect(pruner.instance_variable_get('@keep')).to eq(expected_value)
        end
      end
    end

    it 'should accept strategies with number of screens' do
      screens_count = 50
      pruner = Capybara::Screenshot::Pruner.new(keep: screens_count)
      expect(pruner.instance_variable_get('@keep')).to eq(screens_count)
    end

    it 'should raise error when trying to add invalid strategy' do
      expect { Capybara::Screenshot::Pruner.new(:invalid_strategy) }.to raise_error
    end
  end

  describe '#prune_old_screenshots' do
    let(:capybara_root) { '/tmp/capybara-screenshoot' }
    let(:timestamp) { '2012-06-07-08-09-10.000' }
    let(:file_basename) { "screenshot_#{timestamp}" }

    before do
      Capybara::Screenshot.stub(:capybara_root).and_return(capybara_root)
      Timecop.freeze(Time.local(2012, 6, 7, 8, 9, 10, 0))

      FileUtils.mkdir_p(Capybara::Screenshot.capybara_root)

      @files = []
      8.times do |i|
        f = FileUtils.touch("#{Capybara::Screenshot.capybara_root}/2012-06-07-08-09-10.00#{i}")
        @files << f.first
      end
    end

    after do
      FileUtils.rm_rf(Capybara::Screenshot.capybara_root)
    end

    context 'with :keep_all strategy' do
      let!(:pruner) { Capybara::Screenshot::Pruner.new(:keep_all) }

      it 'should not remove screens' do
        pruner.prune_old_screenshots
        filenames = @files.map { |f| f.split('/').last }
        expect(Dir.entries(Capybara::Screenshot.capybara_root).sort_by { |e| e }).to eq(['.', '..'] + filenames)
      end
    end

    context 'with :keep_last_run strategy' do
      let!(:pruner) { Capybara::Screenshot::Pruner.new(:keep_last_run) }

      it 'should remove all screens' do
        pruner.prune_old_screenshots
        expect(Dir.entries(Capybara::Screenshot.capybara_root).sort_by { |e| e }).to eq(['.', '..'])
      end

      it 'should not raise error when dir is missing' do
        FileUtils.rm_rf(Capybara::Screenshot.capybara_root)
        expect { pruner.prune_old_screenshots }.to_not raise_error
      end
    end

    context 'with :keep strategy' do
      let(:keep_count) { 3 }

      let!(:pruner) { Capybara::Screenshot::Pruner.new(keep: keep_count) }

      it 'should keep specified number of screens' do
        pruner.prune_old_screenshots
        filenames = @files.last(keep_count).map { |f| f.split('/').last }
        expect(Dir.entries(Capybara::Screenshot.capybara_root).sort_by { |e| e }).to eq(['.', '..'] + filenames)
      end

      it 'should not raise error when dir is missing' do
        FileUtils.rm_rf(Capybara::Screenshot.capybara_root)
        expect { pruner.prune_old_screenshots }.to_not raise_error
      end
    end
  end
end
