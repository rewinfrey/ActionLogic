require 'ostruct'

module ActionLogic
  extend self

  def self.configure(&block)
    block.call(configuration_options)
  end

  def self.configuration_options
    @configuration_options ||= OpenStruct.new
  end

  def self.benchmark?
    configuration_options.benchmark || false
  end

  def self.benchmark_log
    configuration_options.benchmark_log || $stdout
  end

  def self.benchmark_formatter
    custom_benchmark_formatter || default_formatter
  end

  def self.benchmark_block
    configuration_options.benchmark_block || ActionBenchmark::DefaultBenchmarkBlock.new
  end

  def self.reset!
    @configuration_options = OpenStruct.new
    @custom_benchmark_formatter = nil
    @default_formatter = nil
  end

  def self.custom_benchmark_formatter
    @custom_benchmark_formatter ||= configuration_options.benchmark_formatter &&
      configuration_options.benchmark_formatter.new
  end

  def self.default_formatter
    @default_formatter ||= ActionBenchmark::DefaultFormatter.new
  end
end
