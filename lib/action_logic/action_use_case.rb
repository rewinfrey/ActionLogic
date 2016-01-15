require 'action_logic/action_includes'

module ActionLogic
  module ActionUseCase

    def self.included(klass)
      klass.extend ActionLogic::ActionIncludes
      klass.extend ClassMethods
    end

    module ClassMethods
      def execute(params = {})
        around(params) do |execution_context|
          raise ActionLogic::InvalidUseCaseError.new("ActionUseCase requires at least one ActionTask") if execution_context.tasks.empty?

          execution_context.call

          execution_context.tasks.reduce(execution_context.context) do |context, task|
            execution_context.context = task.execute(context)
            execution_context.context
          end
        end
      end

      def __private__type
        :use_case
      end
    end
  end
end
