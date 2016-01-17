require 'spec_helper'
require 'action_logic'
require 'fixtures/tasks'

module ActionLogic
  describe ActionTask do
    it "knows its type" do
      expect(SimpleTestTask.__private__type).to eq("task")
    end

    it "returns an instance of ActionContext" do
      result = SimpleTestTask.execute()

      expect(result).to be_a(ActionLogic::ActionContext)
    end

    it "sets an attribute and value on the context" do
      result = SimpleTestTask.execute()

      expect(result.new_attribute).to be_truthy
    end

    describe "around validations" do
      describe "required attributes and type validation" do
        it "does not raise error if context has required keys and values are of the correct type" do
          expect { ValidateAroundTestTask.execute(Constants::VALID_ATTRIBUTES) }.to_not raise_error
        end

        it "raises error if context is missing required keys" do
          expect { ValidateAroundTestTask.execute() }.to\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "raises error if context has required keys but values are not of correct type" do
          expect { ValidateAroundTestTask.execute(Constants::INVALID_ATTRIBUTES) }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "custom types" do
        it "allows validation against custom defined types" do
          expect { ValidateAroundCustomTypeTestTask.execute(:custom_type => CustomType1.new) }.to_not raise_error
        end

        it "raises error if context has custom type attribute but value is not correct custom type" do
          expect { ValidateAroundCustomTypeTestTask.execute(:custom_type => CustomType2.new) }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "presence" do
        it "validates presence if presence is specified" do
          expect { ValidateAroundPresenceTestTask.execute(:integer_test => 1) }.to_not raise_error
        end

        it "raises error if context has required key but value is not defined when validation requires presence" do
          expect { ValidateAroundPresenceTestTask.execute(:integer_test => nil) }.to\
            raise_error(ActionLogic::PresenceError)
        end
      end

      describe "custom presence" do
        it "allows custom presence validation if custom presence is defined" do
          expect { ValidateAroundCustomPresenceTestTask.execute(:array_test => [1]) }.to_not raise_error
        end

        it "raises error if custom presence validation is not satisfied" do
          expect { ValidateAroundCustomPresenceTestTask.execute(:array_test => []) }.to\
            raise_error(ActionLogic::PresenceError)
        end

        it "raises error if custom presence validation is not supported" do
          expect { ValidateAroundUnrecognizablePresenceTestTask.execute(:integer_test => 1) }.to\
            raise_error(ActionLogic::UnrecognizablePresenceValidatorError)
        end
      end
    end

    describe "before validations" do
      describe "required attributes and type validation" do
        it "does not raise error if context has required keys and values are of the correct type" do
          expect { ValidateBeforeTestTask.execute(Constants::VALID_ATTRIBUTES) }.to_not raise_error
        end

        it "raises error if context is missing required keys" do
          expect { ValidateBeforeTestTask.execute() }.to\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "raises error if context has required keys but values are not of correct type" do
          expect { ValidateBeforeTestTask.execute(Constants::INVALID_ATTRIBUTES) }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "custom types" do
        it "allows validation against custom defined types" do
          expect { ValidateBeforeCustomTypeTestTask.execute(:custom_type => CustomType1.new) }.to_not raise_error
        end

        it "raises error if context has custom type attribute but value is not correct custom type" do
          expect { ValidateBeforeCustomTypeTestTask.execute(:custom_type => CustomType2.new) }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "presence" do
        it "validates presence if presence is specified" do
          expect { ValidateBeforePresenceTestTask.execute(:integer_test => 1) }.to_not raise_error
        end

        it "raises error if context has required key but value is not defined when validation requires presence" do
          expect { ValidateBeforePresenceTestTask.execute(:integer_test => nil) }.to\
            raise_error(ActionLogic::PresenceError)
        end
      end

      describe "custom presence" do
        it "allows custom presence validation if custom presence is defined" do
          expect { ValidateBeforeCustomPresenceTestTask.execute(:array_test => [1]) }.to_not raise_error
        end

        it "raises error if custom presence validation is not satisfied" do
          expect { ValidateBeforeCustomPresenceTestTask.execute(:array_test => []) }.to\
            raise_error(ActionLogic::PresenceError)
        end

        it "raises error if custom presence validation is not supported" do
          expect { ValidateBeforeUnrecognizablePresenceTestTask.execute(:integer_test => 1) }.to\
            raise_error(ActionLogic::UnrecognizablePresenceValidatorError)
        end
      end
    end

    describe "after validations" do
      describe "required attributes and type validation" do
        it "does not raise error if the task sets all required keys and values are of the correct type" do
          expect { ValidateAfterTestTask.execute() }.to_not raise_error
        end

        it "raises error if task does not provide the necessary keys" do
          expect { ValidateAfterMissingAttributesTestTask.execute() }.to\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "raises error if task has required key but is not of correct type" do
          expect { ValidateAfterInvalidTypeTestTask.execute() }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "custom types" do
        it "allows validation against custom defined types" do
          expect { ValidateAfterCustomTypeTestTask.execute() }.to_not raise_error
        end

        it "raises error if context has custom type attribute but value is not correct custom type" do
          expect { ValidateAfterInvalidCustomTypeTestTask.execute() }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "presence" do
        it "validates presence if presence is specified" do
          expect { ValidateAfterPresenceTestTask.execute() }.to_not raise_error
        end

        it "raises error if context has required key but value is not defined when validation requires presence" do
          expect { ValidateAfterInvalidPresenceTestTask.execute() }.to\
            raise_error(ActionLogic::PresenceError)
        end
      end

      describe "custom presence" do
        it "allows custom presence validation if custom presence is defined" do
          expect { ValidateAfterCustomPresenceTestTask.execute() }.to_not raise_error
        end

        it "raises error if custom presence validation is not satisfied" do
          expect { ValidateAfterInvalidCustomPresenceTestTask.execute() }.to\
            raise_error(ActionLogic::PresenceError)
        end

        it "raises error if custom presence validation is not supported" do
          expect { ValidateAfterUnrecognizablePresenceTestTask.execute() }.to\
            raise_error(ActionLogic::UnrecognizablePresenceValidatorError)
        end
      end
    end

    describe "error handler" do
      context "with error handler defined" do
        it "does not catch exceptions due to before validation errors" do
          expect { ErrorHandlerInvalidAttributesBeforeTestTask.execute() }.to\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "does not catch exceptions due to after validation errors" do
          expect { ErrorHandlerInvalidAttributesAfterTestTask.execute() }.to\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "the error and context are passed to the error handler" do
          result = ErrorHandlerTestTask.execute()

          expect(result.e).to be_a(RuntimeError)
          expect(result).to be_a(ActionLogic::ActionContext)
        end
      end

      context "without error handler defined" do
        it "raises original exception if error handler is not defined" do
          expect { MissingErrorHandlerTestTask.execute() }.to\
            raise_error(RuntimeError)
        end
      end
    end

    describe "fail!" do
      it "returns the context with the correct status and failure message" do
        result = FailureTestTask.execute()

        expect(result.status).to eq(:failure)
        expect(result.message).to eq(Constants::FAILURE_MESSAGE)
      end
    end

    describe "halt!" do
      it "returns the context with the correct status and halt message" do
        result = HaltTestTask.execute()

        expect(result.status).to eq(:halted)
        expect(result.message).to eq(Constants::HALT_MESSAGE)
      end
    end
  end
end
