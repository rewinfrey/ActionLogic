require 'action_logic/action_core'

module ActionLogic
  module ActionTask
    include ActionLogic::ActionCore

    def execute(params = {})
      around(params) do |context, execution_context|
        execution_context.(context)
        context
      end
    end
  end
end
