require 'action_logic'
require 'fixtures/tasks'
require 'fixtures/constants'

class SimpleTestUseCase
  extend ActionLogic::ActionUseCase

  def call(context)
  end

  def tasks
    [SimpleTestTask]
  end
end

class SimpleTestUseCase2
  extend ActionLogic::ActionUseCase

  def call(context)
  end

  def tasks
    [UseCaseTestTask1,
     UseCaseTestTask2]
  end
end

class SimpleTestUseCase3
  extend ActionLogic::ActionUseCase

  def call(context)
    context.second = "defined in use case"
  end

  def tasks
    [UseCaseTestTask1]
  end
end

class ValidateBeforeTestUseCase
  extend ActionLogic::ActionUseCase

  validates_before Constants::ALL_VALIDATIONS

  def call(context)
  end

  def tasks
    []
  end
end

class ValidateBeforePresenceTestUseCase
  extend ActionLogic::ActionUseCase

  validates_before Constants::PRESENCE_VALIDATION

  def call(context)
  end

  def tasks
    []
  end
end

class ValidateBeforeCustomPresenceTestUseCase
  extend ActionLogic::ActionUseCase

  validates_before Constants::CUSTOM_PRESENCE_VALIDATION

  def call(context)
  end

  def tasks
    []
  end
end

class ValidateBeforeCustomTypeTestUseCase
  extend ActionLogic::ActionUseCase

  validates_before Constants::CUSTOM_TYPE_VALIDATION1

  def call(context)
  end

  def tasks
    []
  end
end

class ValidateAfterTestUseCase
  extend ActionLogic::ActionUseCase

  validates_after Constants::ALL_VALIDATIONS

  def call(context)
    context.integer_test = 1
    context.float_test   = 1.0
    context.string_test  = "string"
    context.bool_test    = false
    context.hash_test    = {}
    context.array_test   = []
    context.symbol_test  = :symbol
    context.nil_test     = nil
  end

  def tasks
    []
  end
end

class ValidateAfterMissingAttributesTestUseCase
  extend ActionLogic::ActionUseCase

  validates_after Constants::ALL_VALIDATIONS

  def call(context)
  end

  def tasks
    []
  end
end

class ValidateAfterInvalidTypeTestUseCase
  extend ActionLogic::ActionUseCase

  validates_after Constants::ALL_VALIDATIONS

  def call(context)
    context.integer_test = nil
    context.float_test   = nil
    context.string_test  = nil
    context.bool_test    = nil
    context.hash_test    = nil
    context.array_test   = nil
    context.symbol_test  = nil
    context.nil_test     = 1
  end

  def tasks
    []
  end
end

class ValidateAfterCustomTypeTestUseCase
  extend ActionLogic::ActionUseCase

  validates_after Constants::CUSTOM_TYPE_VALIDATION1

  def call(context)
    context.custom_type = CustomType1.new
  end

  def tasks
    []
  end
end

class ValidateAfterInvalidCustomTypeTestUseCase
  extend ActionLogic::ActionUseCase

  validates_after Constants::CUSTOM_TYPE_VALIDATION2

  def call(context)
    context.custom_type = CustomType1.new
  end

  def tasks
    []
  end
end

class ValidateAfterPresenceTestUseCase
  extend ActionLogic::ActionUseCase

  validates_after Constants::PRESENCE_VALIDATION

  def call(context)
    context.integer_test = 1
  end

  def tasks
    []
  end
end

class ValidateAfterInvalidPresenceTestUseCase
  extend ActionLogic::ActionUseCase

  validates_after Constants::PRESENCE_VALIDATION

  def call(context)
    context.integer_test = nil
  end

  def tasks
    []
  end
end

class ValidateAfterCustomPresenceTestUseCase
  extend ActionLogic::ActionUseCase

  validates_after Constants::CUSTOM_PRESENCE_VALIDATION

  def call(context)
    context.array_test = [1]
  end

  def tasks
    []
  end
end

class ValidateAfterInvalidCustomPresenceTestUseCase
  extend ActionLogic::ActionUseCase

  validates_after Constants::CUSTOM_PRESENCE_VALIDATION

  def call(context)
    context.array_test = []
  end

  def tasks
    []
  end
end

class FailureTestUseCase
  extend ActionLogic::ActionUseCase

  def call(context)
  end

  def tasks
    [UseCaseTestTask1,
     UseCaseTestTask2,
     UseCaseFailureTestTask,
     UseCaseTestTask3]
  end
end

class HaltTestUseCase
  extend ActionLogic::ActionUseCase

  def call(context)
  end

  def tasks
    [UseCaseTestTask1,
     UseCaseTestTask2,
     UseCaseHaltTestTask,
     UseCaseTestTask3]
  end
end

class UseCaseTestTask1
  extend ActionLogic::ActionTask

  def call(context)
    context.first = "first"
  end
end

class UseCaseTestTask2
  extend ActionLogic::ActionTask

  def call(context)
    context.second = "second"
  end
end

class UseCaseTestTask3
  extend ActionLogic::ActionTask

  def call(context)
    context.third = "third"
  end
end

class UseCaseFailureTestTask
  extend ActionLogic::ActionTask

  def call(context)
    context.fail!(Constants::FAILURE_MESSAGE)
  end
end

class UseCaseHaltTestTask
  extend ActionLogic::ActionTask

  def call(context)
    context.halt!(Constants::HALT_MESSAGE)
  end
end
