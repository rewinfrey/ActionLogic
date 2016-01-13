require 'ostruct'

module ActionLogic
  class ActionConfiguration
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

    def self.reset!
      @configuration_options = OpenStruct.new
    end
  end
end
