require 'spec_helper'
require 'action_logic'
require 'fixtures/tasks'

module ActionLogic
  describe ActionTask do

    it "returns an instance of ActionContext" do
      result = SimpleTestTask.execute()

      expect(result).to be_a(ActionLogic::ActionContext)
    end

    it "sets an attribute and value on the context" do
      result = SimpleTestTask.execute()

      expect(result.new_attribute).to be_truthy
    end

    describe "before validations" do
      describe "required attributes and type validation" do
        it "does not raise error if context has required keys and values are of the correct type" do
          expect { ValidateBeforeTestTask.execute(:integer_test => 1,
                                                  :float_test => 1.0,
                                                  :string_test => "string",
                                                  :bool_test => false,
                                                  :hash_test => {},
                                                  :array_test => [],
                                                  :symbol_test => :symbol,
                                                  :nil_test => nil) }.to_not raise_error
        end

        it "raises error if context is missing required keys" do
          expect { ValidateBeforeTestTask.execute() }.to raise_error(ActionLogic::MissingAttributeError)
        end

        it "raises error if context has required keys but values are not of correct type" do
          expect { ValidateBeforeTestTask.execute(:integer_test => nil,
                                                  :float_test => nil,
                                                  :string_test => nil,
                                                  :bool_test => nil,
                                                  :hash_test => nil,
                                                  :array_test => nil,
                                                  :symbol_test => nil,
                                                  :nil_test => 1) }.to raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "custom types" do
        it "allows validation against custom defined types" do
          expect { ValidateBeforeCustomTypeTestTask.execute(:custom_type => CustomType1.new) }.to_not raise_error
        end

        it "raises error if context has custom type attribute but value is not correct custom type" do
          expect { ValidateBeforeCustomTypeTestTask.execute(:custom_type => CustomType2.new) }.to raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "presence" do
        it "validates presence if presence is specified" do
          expect { ValidateBeforePresenceTestTask.execute(:integer_test => 1) }.to_not raise_error
        end

        it "raises error if context has required key but value is not defined when validation requires presence" do
          expect { ValidateBeforePresenceTestTask.execute(:integer_test => nil) }.to raise_error(ActionLogic::PresenceError)
        end
      end

      describe "custom presence" do
        it "allows custom presence validation if custom presence is defined" do
          expect { ValidateBeforeCustomPresenceTestTask.execute(:array_test => [1]) }.to_not raise_error
        end

        it "raises error if custom presence validation is not satisfied" do
          expect { ValidateBeforeCustomPresenceTestTask.execute(:array_test => []) }.to raise_error(ActionLogic::PresenceError)
        end
      end
    end

    describe "after validations" do
      it "does not raise error if the task sets all required keys and values are of the correct type" do
        expect { ValidateAfterTestTask.execute() }.to_not raise_error
      end

      it "raises error if task does not set the required keys" do
        expect { ValidateAfterMissingAttributesTestTask.execute() }.to\
          raise_error(ActionLogic::MissingAttributeError)
      end

      it "raises error if task sets required keys but values are not of the correct type" do
        expect { ValidateAfterTypeTestTask.execute() }.to\
          raise_error(ActionLogic::AttributeTypeError)
      end
    end
  end
end
