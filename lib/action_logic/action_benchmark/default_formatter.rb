module ActionLogic
  module ActionBenchmark
    class DefaultFormatter
      def initialize(benchmark_log: ActionLogic.benchmark_log)
        @benchmark_log = benchmark_log
      end

      def format(benchmark_result, context_name)
        benchmark_log.printf("%s%s %s%f %s%f %s%f %s%f\n",
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

      alias_method :log_coordinator, :format
      alias_method :log_use_case, :format
      alias_method :log_task, :format

      private
      attr_reader :benchmark_log
    end
  end
end
