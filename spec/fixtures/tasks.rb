require 'action_logic'
require 'fixtures/custom_types'
require 'fixtures/validations'

class SimpleTestTask
  extend ActionLogic::ActionTask

  def call(context)
    context.new_attribute = true
  end
end

class ValidateBeforeTestTask
  extend ActionLogic::ActionTask

  validates_before Validations::ALL_VALIDATIONS

  def call(context)
  end
end

class ValidateBeforeCustomTypeTestTask
  extend ActionLogic::ActionTask

  validates_before :custom_type => { :type => :customtype1, :presence => true }

  def call(context)
  end
end

class ValidateBeforePresenceTestTask
  extend ActionLogic::ActionTask

  validates_before :integer_test => { :presence => true }

  def call(context)
  end
end

class ValidateBeforeCustomPresenceTestTask
  extend ActionLogic::ActionUseCase

  validates_before :array_test => { :presence => ->(array_test) { array_test.any? } }

  def call(context)
  end

  def tasks
    []
  end
end

class ValidateAfterTestTask
  extend ActionLogic::ActionTask

  validates_after Validations::ALL_VALIDATIONS

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
end

class ValidateAfterMissingAttributesTestTask
  extend ActionLogic::ActionTask

  validates_after Validations::ALL_VALIDATIONS

  def call(context)
  end
end

class ValidateAfterInvalidTypeTestTask
  extend ActionLogic::ActionTask

  validates_after Validations::ALL_VALIDATIONS

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
end

class ValidateAfterCustomTypeTestTask
  extend ActionLogic::ActionTask

  validates_after :custom_type => { :type => :customtype1, :presence => true }

  def call(context)
    context.custom_type = CustomType1.new
  end
end

class ValidateAfterInvalidCustomTypeTestTask
  extend ActionLogic::ActionTask

  validates_after :custom_type => { :type => :customtype2, :presence => true }

  def call(context)
    context.custom_type = CustomType1.new
  end
end

class ValidateAfterPresenceTestTask
  extend ActionLogic::ActionTask

  validates_after :integer_test => { :presence => true }

  def call(context)
    context.integer_test = 1
  end
end

class ValidateAfterInvalidPresenceTestTask
  extend ActionLogic::ActionTask

  validates_after :integer_test => { :presence => true }

  def call(context)
    context.integer_test = nil
  end
end

class ValidateAfterCustomPresenceTestTask
  extend ActionLogic::ActionTask

  validates_after :array_test => { :presence => ->(array_test) { array_test.any? } }

  def call(context)
    context.array_test = [1]
  end
end

class ValidateAfterInvalidCustomPresenceTestTask
  extend ActionLogic::ActionTask

  validates_after :array_test => { :presence => ->(array_test) { array_test.any? } }

  def call(context)
    context.array_test = []
  end
end

class ErrorHandlerTestTask
  extend ActionLogic::ActionTask

  def call(context)
    raise
  end

  def error(e, context)
    context.e = e
    context.context = context
  end
end

class ErrorHandlerInvalidAttributesBeforeTestTask
  extend ActionLogic::ActionTask

  validates_before Validations::ALL_VALIDATIONS

  def call(context)
    raise
  end

  def error(e, context)
    context.error = "error"
  end
end

class ErrorHandlerInvalidAttributesAfterTestTask
  extend ActionLogic::ActionTask

  validates_after Validations::ALL_VALIDATIONS

  def call(context)
    raise
  end

  def error(e, context)
    context.error = "error"
  end
end

class MissingErrorHandlerTestTask
  extend ActionLogic::ActionTask

  def call(context)
    raise
  end
end
