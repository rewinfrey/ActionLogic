module ActionLogic
  module ActionBenchmark
    module ClassMethods
      def with_benchmark(execution_context, &block)
        ActionLogic.benchmark? ? benchmark!(execution_context, &block) : block.call
      end

      private

      def benchmark!(execution_context, &block)
        context = nil
        benchmark_result  = ActionLogic.benchmark_block.call { context = block.call }
        log!(benchmark_result, execution_context)
        context
      end

      def log!(benchmark_result, execution_context)
        ActionLogic.benchmark_formatter.send("log_#{execution_context.__private__type}".to_sym,
                                             benchmark_result,
                                             execution_context.name)
      end

    end
  end
end
