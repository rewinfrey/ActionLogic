module ActionLogic
  module ActionBenchmark
    class DefaultFormatter
      def initialize(benchmark_log: ActionConfiguration.benchmark_log)
        @benchmark_log = benchmark_log
      end

      def format(benchmark_result, context_name)
        benchmark_log.printf("%-10s %-50s %-10s %-10f %-10s %-10f %-10s %-10f %-10s %-10f\n",
                             "context:",
                             context_name,
                             "user_time:",
                             benchmark_result.utime,
                             "system_time:",
                             benchmark_result.stime,
                             "total_time:",
                             benchmark_result.total,
                             "real_time:",
                             benchmark_result.real)
      end

      alias_method :coordinator, :format
      alias_method :use_case, :format
      alias_method :task, :format

      private
      attr_reader :benchmark_log
    end
  end
end
