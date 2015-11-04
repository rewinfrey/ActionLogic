require 'spec_helper'
require 'active_logic'
require 'test_tasks'

module ActiveLogic
  describe ActiveTask do

    it "returns an instance of ActiveContext" do
      result = SimpleTestTask.execute()

      expect(result).to be_a(ActiveLogic::ActiveContext)
    end

    it "sets an attribute and value on the context" do
      result = SimpleTestTask.execute()

      expect(result.new_attribute).to be_truthy
    end

    describe "before validations" do
      it "does not raise error if the context has all required keys" do
        expect { ValidateBeforeTestTask.execute(:integer_test => 1,
                                                :float_test => 1.0,
                                                :string_test => "string") }.to_not raise_error
      end

      it "raises error if context is missing required keys" do
        expect { ValidateBeforeTestTask.execute() }.to raise_error(ActiveLogic::MissingAttributeError)
      end

      it "does not raise error if context has required keys and values are of the correct type" do
        expect { ValidateBeforeTestTask.execute(:integer_test => 1,
                                                :float_test => 1.0,
                                                :string_test => "string") }.to_not raise_error
      end

      it "raises error if context has required key but is not of correct type" do
        expect { ValidateBeforeTestTask.execute(:integer_test => 1.0,
                                                :float_test => 1.0,
                                                :string_test => "string") }.to raise_error(ActiveLogic::AttributeTypeError)
      end
    end

    describe "after validations" do
      it "does not raise error if the task sets all required keys on the context" do
        expect { ValidateAfterTestTask.execute() }.to_not raise_error
      end

      it "raises error if task does not provide the necessary keys" do
        expect { ValidateAfterMissingAttributesTestTask.execute() }.to raise_error(ActiveLogic::MissingAttributeError)
      end

      it "does not raise error if the task sets all required keys and values are of the correct type" do
        expect { ValidateAfterTestTask.execute() }.to_not raise_error
      end

      it "raises error if task has required key but is not of correct type" do
        expect { ValidateAfterTypeTestTask.execute() }.to raise_error(ActiveLogic::AttributeTypeError)
      end
    end
  end
end
