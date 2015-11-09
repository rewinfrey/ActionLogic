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
        execution_context = self.new(params)

        return execution_context.context if execution_context.break?

        execution_context.set_validation_rules
        execution_context.before_validations!

        begin
          block.call(execution_context)
        rescue => e
          if execution_context.respond_to?(:error)
            execution_context.error(e)
          else
            raise e
          end
        end

        execution_context.after_validations!

        execution_context.context
      end
    end
  end
end
