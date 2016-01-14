require 'action_logic'
require 'fixtures/constants'

# :nocov:
class TestCoordinator1
  include ActionLogic::ActionCoordinator

  def call
    context.test_coordinator1 = true
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class HaltedTestCoordinator1
  include ActionLogic::ActionCoordinator

  def call
    context.halted_test_coordinator1 = true
  end

  def plan
    {
      HaltedTestUseCase1 => { :success => nil,
                              :halted  => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class FailureTestCoordinator1
  include ActionLogic::ActionCoordinator

  def call
    context.failure_test_coordinator1 = true
  end

  def plan
    {
      FailureTestUseCase1 => { :success => nil,
                               :failure  => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateBeforeTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_before Constants::ALL_VALIDATIONS

  def call
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateBeforeCustomTypeTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_before Constants::CUSTOM_TYPE_VALIDATION1

  def call
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateBeforePresenceTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_before Constants::PRESENCE_VALIDATION

  def call
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateBeforeCustomPresenceTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_before Constants::CUSTOM_PRESENCE_VALIDATION

  def call
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateBeforeUnrecognizablePresenceTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_before :integer_test => { :presence => :true }

  def call
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterTestCoordinator
  include ActionLogic::ActionCoordinator

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

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterMissingAttributesTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_after Constants::ALL_VALIDATIONS

  def call
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterInvalidTypeTestCoordinator
  include ActionLogic::ActionCoordinator

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

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterCustomTypeTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_after Constants::CUSTOM_TYPE_VALIDATION1

  def call
    context.custom_type = CustomType1.new
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterInvalidCustomTypeTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_after Constants::CUSTOM_TYPE_VALIDATION2

  def call
    context.custom_type = CustomType1.new
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterPresenceTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_after Constants::PRESENCE_VALIDATION

  def call
    context.integer_test = 1
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterInvalidPresenceTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_after Constants::PRESENCE_VALIDATION

  def call
    context.integer_test = nil
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterCustomPresenceTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_after Constants::CUSTOM_PRESENCE_VALIDATION

  def call
    context.array_test = [1]
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterInvalidCustomPresenceTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_after Constants::CUSTOM_PRESENCE_VALIDATION

  def call
    context.array_test = []
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterUnrecognizablePresenceTestCoordinator
  include ActionLogic::ActionCoordinator

  validates_after :integer_test => { :presence => :true }

  def call
    context.integer_test = 1
  end

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class TestUseCase1
  include ActionLogic::ActionUseCase

  def call
    context.test_use_case1 = true
  end

  def tasks
    [TestTask1]
  end
end

class TestHaltUseCase1
  include ActionLogic::ActionUseCase

  def call
    context.test_use_case1 = true
  end

  def tasks
    [HaltTestTask1]
  end
end

class TestUseCase2
  include ActionLogic::ActionUseCase

  def call
    context.test_use_case2 = true
  end

  def tasks
    [TestTask2]
  end
end

class TestUseCase3
  include ActionLogic::ActionUseCase

  def call
    context.test_use_case3 = true
  end

  def tasks
    [TestTask3]
  end
end

class HaltedTestUseCase1
  include ActionLogic::ActionUseCase

  def call
    context.halted_test_use_case1 = true
  end

  def tasks
    [HaltedTestTask1]
  end
end

class HaltedTestUseCase2
  include ActionLogic::ActionUseCase

  def call
    context.halted_test_use_case2 = true
  end

  def tasks
    [HaltedTestTask2]
  end
end

class HaltedTestUseCase3
  include ActionLogic::ActionUseCase

  def call
    context.halted_test_use_case3 = true
  end

  def tasks
    [HaltedTestTask3]
  end
end

class FailureTestUseCase1
  include ActionLogic::ActionUseCase

  def call
    context.failure_test_use_case1 = true
  end

  def tasks
    [FailureTestTask1]
  end
end

class FailureTestUseCase2
  include ActionLogic::ActionUseCase

  def call
    context.failure_test_use_case2 = true
  end

  def tasks
    [FailureTestTask2]
  end
end

class FailureTestUseCase3
  include ActionLogic::ActionUseCase

  def call
    context.failure_test_use_case3 = true
  end

  def tasks
    [FailureTestTask3]
  end
end

class TestTask1
  include ActionLogic::ActionTask

  def call
    context.test_task1 = true
  end
end

class TestTask2
  include ActionLogic::ActionTask

  def call
    context.test_task2 = true
  end
end

class TestTask3
  include ActionLogic::ActionTask

  def call
    context.test_task3 = true
  end
end

class HaltedTestTask1
  include ActionLogic::ActionTask

  def call
    context.halted_test_task1 = true
    context.halt!
  end
end

class HaltedTestTask2
  include ActionLogic::ActionTask

  def call
    context.halted_test_task2 = true
    context.halt!
  end
end

class HaltedTestTask3
  include ActionLogic::ActionTask

  def call
    context.halted_test_task3 = true
    context.halt!
  end
end

class FailureTestTask1
  include ActionLogic::ActionTask

  def call
    context.failure_test_task1 = true
    context.fail!
  end
end

class FailureTestTask2
  include ActionLogic::ActionTask

  def call
    context.failure_test_task2 = true
    context.fail!
  end
end

class FailureTestTask3
  include ActionLogic::ActionTask

  def call
    context.failure_test_task3 = true
    context.fail!
  end
end
# :nocov:
