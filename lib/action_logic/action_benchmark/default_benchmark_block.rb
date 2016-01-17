require 'benchmark'

module ActionLogic
  module ActionBenchmark
    class DefaultBenchmarkBlock
      def call
        Benchmark.measure { yield }
      end
    end
  end
end
