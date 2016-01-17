require 'benchmark'

module ActionLogic
  module ActionBenchmark
    class DefaultBenchmarkHandler
      def call
        Benchmark.measure { yield }
      end
    end
  end
end
