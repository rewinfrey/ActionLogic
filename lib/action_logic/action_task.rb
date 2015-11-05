require 'pp'
require 'action_logic/errors'
require 'action_logic/util'

module ActionLogic
  module ActionTask
    include ActionLogic::Util

    def execute(params = {})
      around(params) do |context, execution_context|
        execution_context.(context)
        context
      end
    end
  end
end
