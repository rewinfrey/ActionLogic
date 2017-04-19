module ActionLogic
  module ActionCore
    attr_accessor :context

    def initialize(params)
      self.context = make_context(params)
    end

    def make_context(params = {})
      ActionContext.new(params)
    end

    def break?
      context.status == :failure ||
        context.status == :halted
    end

    module ClassMethods
      def around(params, &block)
        with_benchmark(self) do
          execute!(params, &block)
        end
      end

      def execute!(params, &block)
        execution_context = self.new(params)

        return execution_context.context if execution_context.break?

        execution_context.set_validation_rules
        execution_context.validations!(:before!)
        execution_context.validations!(:around!)

        begin
          block.call(execution_context)
        rescue => e
          if execution_context.respond_to?(:error)
            execution_context.error(e)
          else
            raise e
          end
        end

        execution_context.validations!(:after!)
        execution_context.validations!(:around!)

        execution_context.context
      end
    end
  end
end
