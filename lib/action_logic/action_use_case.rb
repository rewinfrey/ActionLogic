require 'action_logic/action_core'

module ActionLogic
  module ActionUseCase
    include ActionLogic::ActionCore

    def execute(params = {})
      around(params) do |context, execution_context|
        execution_context.(context)

        execution_context.tasks.reduce(context) do |context, task|
          task.execute(context)
        end
      end
    end
  end
end
