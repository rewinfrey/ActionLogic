require 'action_logic'
require 'fixtures/custom_types'
require 'fixtures/constants'
# :nocov:
class SimpleTestTask
  include ActionLogic::ActionTask

  def call
    context.new_attribute = true
  end
end

class ValidateAroundTestTask
  include ActionLogic::ActionTask

  validates_around Constants::ALL_VALIDATIONS

  def call
  end
end

class ValidateAroundCustomTypeTestTask
  include ActionLogic::ActionTask

  validates_around :custom_type => { :type => CustomType1, :presence => true }

  def call
  end
end

class ValidateAroundUnrecognizablePresenceTestTask
  include ActionLogic::ActionTask

  validates_around :integer_test => { :presence => :true }

  def call
  end
end

class ValidateAroundPresenceTestTask
  include ActionLogic::ActionTask

  validates_around :integer_test => { :presence => true }

  def call
  end
end

class ValidateAroundCustomPresenceTestTask
  include ActionLogic::ActionTask

  validates_around :array_test => { :presence => ->(array_test) { array_test.any? } }

  def call
  end

  def tasks
    []
  end
end

class ValidateBeforeTestTask
  include ActionLogic::ActionTask

  validates_before Constants::ALL_VALIDATIONS

  def call
  end
end

class ValidateBeforeCustomTypeTestTask
  include ActionLogic::ActionTask

  validates_before :custom_type => { :type => CustomType1, :presence => true }

  def call
  end
end

class ValidateBeforeUnrecognizablePresenceTestTask
  include ActionLogic::ActionTask

  validates_before :integer_test => { :presence => :true }

  def call
  end
end

class ValidateBeforePresenceTestTask
  include ActionLogic::ActionTask

  validates_before :integer_test => { :presence => true }

  def call
  end
end

class ValidateBeforeCustomPresenceTestTask
  include ActionLogic::ActionTask

  validates_before :array_test => { :presence => ->(array_test) { array_test.any? } }

  def call
  end

  def tasks
    []
  end
end

class ValidateAfterTestTask
  include ActionLogic::ActionTask

  validates_after Constants::ALL_VALIDATIONS

  def call
    context.integer_test = 1
    context.float_test   = 1.0
    context.string_test  = "string"
    context.bool_test    = true
    context.hash_test    = {}
    context.array_test   = []
    context.symbol_test  = :symbol
    context.nil_test     = nil
  end
end

class ValidateAfterMissingAttributesTestTask
  include ActionLogic::ActionTask

  validates_after Constants::ALL_VALIDATIONS

  def call
  end
end

class ValidateAfterInvalidTypeTestTask
  include ActionLogic::ActionTask

  validates_after Constants::ALL_VALIDATIONS

  def call
    context.integer_test = nil
    context.float_test   = nil
    context.string_test  = nil
    context.bool_test    = nil
    context.hash_test    = nil
    context.array_test   = nil
    context.symbol_test  = nil
    context.nil_test     = 1
  end
end

class ValidateAfterCustomTypeTestTask
  include ActionLogic::ActionTask

  validates_after :custom_type => { :type => CustomType1, :presence => true }

  def call
    context.custom_type = CustomType1.new
  end
end

class ValidateAfterInvalidCustomTypeTestTask
  include ActionLogic::ActionTask

  validates_after :custom_type => { :type => CustomType2, :presence => true }

  def call
    context.custom_type = CustomType1.new
  end
end

class ValidateAfterPresenceTestTask
  include ActionLogic::ActionTask

  validates_after :integer_test => { :presence => true }

  def call
    context.integer_test = 1
  end
end

class ValidateAfterInvalidPresenceTestTask
  include ActionLogic::ActionTask

  validates_after :integer_test => { :presence => true }

  def call
    context.integer_test = nil
  end
end

class ValidateAfterCustomPresenceTestTask
  include ActionLogic::ActionTask

  validates_after :array_test => { :presence => ->(array_test) { array_test.any? } }

  def call
    context.array_test = [1]
  end
end

class ValidateAfterInvalidCustomPresenceTestTask
  include ActionLogic::ActionTask

  validates_after :array_test => { :presence => ->(array_test) { array_test.any? } }

  def call
    context.array_test = []
  end
end

class ValidateAfterUnrecognizablePresenceTestTask
  include ActionLogic::ActionTask

  validates_after :integer_test => { :presence => :true }

  def call
    context.integer_test = 1
  end
end

class ErrorHandlerTestTask
  include ActionLogic::ActionTask

  def call
    raise
  end

  def error(e)
    context.e = e
  end
end

class ErrorHandlerInvalidAttributesBeforeTestTask
  include ActionLogic::ActionTask

  validates_before Constants::ALL_VALIDATIONS

  def call
    raise
  end

  def error(e)
    context.error = "error"
  end
end

class ErrorHandlerInvalidAttributesAfterTestTask
  include ActionLogic::ActionTask

  validates_after Constants::ALL_VALIDATIONS

  def call
    raise
  end

  def error(e)
    context.error = "error"
  end
end

class MissingErrorHandlerTestTask
  include ActionLogic::ActionTask

  def call
    raise
  end
end

class FailureTestTask
  include ActionLogic::ActionTask

  def call
    context.fail!(Constants::FAILURE_MESSAGE)
  end
end

class HaltTestTask
  include ActionLogic::ActionTask

  def call
    context.halt!(Constants::HALT_MESSAGE)
  end
end

class UseCaseTestTask1
  include ActionLogic::ActionTask

  def call
    context.first = "first"
  end
end

class UseCaseTestTask2
  include ActionLogic::ActionTask

  def call
    context.second = "second"
  end
end

class UseCaseTestTask3
  include ActionLogic::ActionTask

  def call
    context.third = "third"
  end
end

class UseCaseFailureTestTask
  include ActionLogic::ActionTask

  def call
    context.fail!(Constants::FAILURE_MESSAGE)
  end
end

class UseCaseHaltTestTask
  include ActionLogic::ActionTask

  def call
    context.halt!(Constants::HALT_MESSAGE)
  end
end
# :nocov:
