require 'active_logic'

class SimpleTestTask
  extend ActiveLogic::ActiveTask

  def call(context)
    context.new_attribute = true
  end
end

class ValidateBeforeTestTask
  extend ActiveLogic::ActiveTask

  validates_before :integer_test => { :type => :integer, :presence => true },
                   :float_test =>   { :type => :float },
                   :string_test =>  { :type => :string }

  def call(context)
  end
end

class ValidateAfterTestTask
  extend ActiveLogic::ActiveTask

  validates_after :integer_test => { :type => :integer, :presence => true },
                  :float_test =>   { :type => :float },
                  :string_test =>  { :type => :string }

  def call(context)
    context.integer_test = 1
    context.float_test   = 1.0
    context.string_test  = "string"
  end
end

class ValidateAfterMissingAttributesTestTask
  extend ActiveLogic::ActiveTask

  validates_after :integer_test => { :type => :integer, :presence => true },
                  :float_test =>   { :type => :float },
                  :string_test =>  { :type => :string }

  def call(context)
  end
end

class ValidateAfterTypeTestTask
  extend ActiveLogic::ActiveTask

  validates_after :integer_test => { :type => :integer, :presence => true },
                  :float_test =>   { :type => :float },
                  :string_test =>  { :type => :string }

  def call(context)
    context.integer_test = 1.0
    context.float_test   = 1
    context.string_test  = 1
  end
end
