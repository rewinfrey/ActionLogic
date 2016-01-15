require 'benchmark'

module ActionLogic
  module ActionBenchmark

    module ClassMethods
      def with_benchmark(execution_context, &block)
        if benchmark?
          benchmark_result, context = benchmark!(&block)
          log!(benchmark_result, execution_context)
          context
        else
          block.call
        end
      end

      private

      def benchmark?
        ActionConfiguration.benchmark?
      end

      def benchmark!(&block)
        context = nil
        benchmark_result  = Benchmark.measure { context = block.call }
        [benchmark_result, context]
      end

      def log!(benchmark_result, execution_context)
        benchmark_formatter.send(execution_context.__private__type, benchmark_result, execution_context.name)
      end

      def benchmark_formatter
        ActionConfiguration.benchmark_formatter
      end
    end
  end
end
