require 'action_logic/action_core'
require 'action_logic/action_validation'
require 'action_logic/action_benchmark'

module ActionLogic
  module ActionUseCase
    include ActionLogic::ActionValidation
    include ActionLogic::ActionCore

    def self.included(klass)
      klass.extend ClassMethods
      klass.extend ActionLogic::ActionCore::ClassMethods
      klass.extend ActionLogic::ActionValidation::ClassMethods
      klass.extend ActionLogic::ActionBenchmark::ClassMethods
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
    end
  end
end
