require 'spec_helper'
require 'stringio'
require 'action_logic'

module ActionLogic
  describe ActionConfiguration do
    subject { described_class }

    before do
      described_class.reset!
    end

    context "benchmark" do
      it "defaults the benchmark configuration option to false" do
        expect(described_class.benchmark?).to be_falsey
      end

      it "returns true when the benchmark configuration option is set to true" do
        described_class.configure do |config|
          config.benchmark = true
        end

        expect(described_class.benchmark?).to be_truthy
      end
    end

    context "benchmark_log" do
      it "defaults benchmark log file to stdout" do
        expect(described_class.benchmark_log).to eq($stdout)
      end

      it "returns the log file when the benchmark log configuration option is set" do
        temp_file = StringIO.new

        described_class.configure do |config|
          config.benchmark_log = temp_file
        end

        expect(described_class.benchmark_log).to eq(temp_file)
      end
    end
  end
end
