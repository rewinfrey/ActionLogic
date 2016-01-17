require 'spec_helper'
require 'action_logic'

describe ActionLogic do

  subject { described_class }

  around do |example|
    described_class.reset!
    example.run
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
      temp_file = Object.new

      described_class.configure do |config|
        config.benchmark_log = temp_file
      end

      expect(described_class.benchmark_log).to eq(temp_file)
    end
  end

  context "benchmark_formatter" do
    it "uses default formatter if a custom formatter is not provided" do
      expect(described_class.benchmark_formatter).to be_a(ActionLogic::ActionBenchmark::DefaultFormatter)
    end

    it "uses a custom formatter if one is provided" do
      class CustomFormatter; end

      described_class.configure do |config|
        config.benchmark_formatter = CustomFormatter
      end

      expect(described_class.benchmark_formatter).to be_a(CustomFormatter)
    end
  end

  context "benchmark_block" do
    it "uses a default benchmark block if a custom benchmark block is not provided" do
      expect(described_class.benchmark_block).to be_a(ActionLogic::ActionBenchmark::DefaultBenchmarkBlock)
    end

    it "uses a custom benchmark block if one is provided" do
      custom_benchmark_block = -> { yield }

      described_class.configure do |config|
        config.benchmark_block = custom_benchmark_block
      end

      expect(described_class.benchmark_block).to eq(custom_benchmark_block)
    end
  end
end
