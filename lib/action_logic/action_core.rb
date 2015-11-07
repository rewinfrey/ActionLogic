require 'action_logic/action_validation'

module ActionLogic
  module ActionCore
    include ActionLogic::ActionValidation

    def make_context(params = {})
      ActionContext.new(params)
    end

    def break?(context)
      context.status == :failure ||
        context.status == :halted
    end

    def around(params, &blk)
      context = make_context(params)

      return context if break?(context)

      default_validations
      execution_context = self.new

      validations.each { |validation| self.send(validation, context, @validates_before) }

      begin
        context = blk.call(context, execution_context)
      rescue => e
        if execution_context.respond_to?(:error)
          execution_context.error(e, context)
        else
          raise e
        end
      end

      validations.each { |validation| self.send(validation, context, @validates_after) }

      context
    end

  end
end
