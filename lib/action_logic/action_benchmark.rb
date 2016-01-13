module ActionLogic
  module ActionBenchmark

    module ClassMethods
      def with_benchmark(class_context, &block)
        if ActionConfiguration.benchmark?
          context = nil
          benchmark_result = Benchmark.measure { context = block.call }
          ActionConfiguration.benchmark_log.printf("%60s: %15s %15s %15s %15s\n", "Context", "User Time", "System Time", "Total Time", "Real Time")
          ActionConfiguration.benchmark_log.printf("%60s: %15f %15f %15f %15f\n\n", class_context, benchmark_result.utime, benchmark_result.stime, benchmark_result.total, benchmark_result.real)
          context
        else
          block.call
        end
      end
    end

  end
end
