require 'action_logic/action_core'
require 'action_logic/action_validation'
require 'action_logic/action_benchmark'

module ActionLogic
  module ActionIncludes
    def self.extended(klass)
      klass.include ActionLogic::ActionCore
      klass.include ActionLogic::ActionValidation
      klass.extend  ActionLogic::ActionCore::ClassMethods
      klass.extend  ActionLogic::ActionValidation::ClassMethods
      klass.extend  ActionLogic::ActionBenchmark::ClassMethods
    end
  end
end
