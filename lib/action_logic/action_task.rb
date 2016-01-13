require 'action_logic/action_core'
require 'action_logic/action_validation'
require 'action_logic/action_benchmark'

module ActionLogic
  module ActionTask
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
          execution_context.call
          execution_context.context
        end
      end
    end
  end
end
