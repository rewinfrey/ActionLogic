require 'action_logic/action_includes'

module ActionLogic
  module ActionTask

    def self.included(klass)
      klass.extend ActionLogic::ActionIncludes
      klass.extend ClassMethods
    end

    module ClassMethods
      def execute(params = {})
        around(params) do |execution_context|
          execution_context.call
          execution_context.context
        end
      end

      def __private__type
        "task"
      end
    end
  end
end
