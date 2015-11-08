require 'action_logic'
require 'fixtures/constants'

class TestCoordinator1
  extend ActionLogic::ActionCoordinator

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_before Constants::ALL_VALIDATIONS

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_before Constants::CUSTOM_TYPE_VALIDATION1

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_before Constants::PRESENCE_VALIDATION

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_before Constants::CUSTOM_PRESENCE_VALIDATION

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_before :integer_test => { :presence => :true }

  def call(context)
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
  extend ActionLogic::ActionCoordinator

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

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterMissingAttributesTestCoordinator
  extend ActionLogic::ActionCoordinator

  validates_after Constants::ALL_VALIDATIONS

  def call(context)
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
  extend ActionLogic::ActionCoordinator

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

  def plan
    {
      TestUseCase1 => { :success => TestUseCase2 },

      TestUseCase2 => { :success => TestUseCase3 },

      TestUseCase3 => { :success => nil }
    }
  end
end

class ValidateAfterCustomTypeTestCoordinator
  extend ActionLogic::ActionCoordinator

  validates_after Constants::CUSTOM_TYPE_VALIDATION1

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_after Constants::CUSTOM_TYPE_VALIDATION2

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_after Constants::PRESENCE_VALIDATION

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_after Constants::PRESENCE_VALIDATION

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_after Constants::CUSTOM_PRESENCE_VALIDATION

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_after Constants::CUSTOM_PRESENCE_VALIDATION

  def call(context)
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
  extend ActionLogic::ActionCoordinator

  validates_after :integer_test => { :presence => :true }

  def call(context)
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
  extend ActionLogic::ActionUseCase

  def call(context)
    context.test_use_case1 = true
  end

  def tasks
    [TestTask1]
  end
end

class TestHaltUseCase1
  extend ActionLogic::ActionUseCase

  def call(context)
    context.test_use_case1 = true
  end

  def tasks
    [HaltTestTask1]
  end
end

class TestUseCase2
  extend ActionLogic::ActionUseCase

  def call(context)
    context.test_use_case2 = true
  end

  def tasks
    [TestTask2]
  end
end

class TestUseCase3
  extend ActionLogic::ActionUseCase

  def call(context)
    context.test_use_case3 = true
  end

  def tasks
    [TestTask3]
  end
end

class HaltedTestUseCase1
  extend ActionLogic::ActionUseCase

  def call(context)
    context.halted_test_use_case1 = true
  end

  def tasks
    [HaltedTestTask1]
  end
end

class HaltedTestUseCase2
  extend ActionLogic::ActionUseCase

  def call(context)
    context.halted_test_use_case2 = true
  end

  def tasks
    [HaltedTestTask2]
  end
end

class HaltedTestUseCase3
  extend ActionLogic::ActionUseCase

  def call(context)
    context.halted_test_use_case3 = true
  end

  def tasks
    [HaltedTestTask3]
  end
end

class FailureTestUseCase1
  extend ActionLogic::ActionUseCase

  def call(context)
    context.failure_test_use_case1 = true
  end

  def tasks
    [FailureTestTask1]
  end
end

class FailureTestUseCase2
  extend ActionLogic::ActionUseCase

  def call(context)
    context.failure_test_use_case2 = true
  end

  def tasks
    [FailureTestTask2]
  end
end

class FailureTestUseCase3
  extend ActionLogic::ActionUseCase

  def call(context)
    context.failure_test_use_case3 = true
  end

  def tasks
    [FailureTestTask3]
  end
end

class TestTask1
  extend ActionLogic::ActionTask

  def call(context)
    context.test_task1 = true
  end
end

class TestTask2
  extend ActionLogic::ActionTask

  def call(context)
    context.test_task2 = true
  end
end

class TestTask3
  extend ActionLogic::ActionTask

  def call(context)
    context.test_task3 = true
  end
end

class HaltedTestTask1
  extend ActionLogic::ActionTask

  def call(context)
    context.halted_test_task1 = true
    context.halt!
  end
end

class HaltedTestTask2
  extend ActionLogic::ActionTask

  def call(context)
    context.halted_test_task2 = true
    context.halt!
  end
end

class HaltedTestTask3
  extend ActionLogic::ActionTask

  def call(context)
    context.halted_test_task3 = true
    context.halt!
  end
end

class FailureTestTask1
  extend ActionLogic::ActionTask

  def call(context)
    context.failure_test_task1 = true
    context.fail!
  end
end

class FailureTestTask2
  extend ActionLogic::ActionTask

  def call(context)
    context.failure_test_task2 = true
    context.fail!
  end
end

class FailureTestTask3
  extend ActionLogic::ActionTask

  def call(context)
    context.failure_test_task3 = true
    context.fail!
  end
end
