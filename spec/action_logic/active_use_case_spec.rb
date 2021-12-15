require 'spec_helper'
require 'action_logic'
require 'fixtures/use_cases'
require 'fixtures/custom_types'

module ActionLogic
  describe ActionUseCase do
    it "knows its type" do
      expect(SimpleTestUseCase.__private__type).to eq("use_case")
    end

    it "returns an instance of ActionContext" do
      result = SimpleTestUseCase.execute()

      expect(result).to be_a(ActionLogic::ActionContext)
    end

    it "evalutes a task defined by the use case" do
      result = SimpleTestUseCase.execute()

      expect(result.new_attribute).to be_truthy
    end

    it "evalutes multiple tasks defined by the use case" do
      result = SimpleTestUseCase2.execute()

      expect(result.first).to eq("first")
      expect(result.second).to eq("second")
    end

    it "calls the use case before evaluating the tasks" do
      result = SimpleTestUseCase3.execute()

      expect(result.first).to eq("first")
      expect(result.second).to eq("defined in use case")
    end

    describe "missing tasks" do
      it "raises error if no tasks are defined" do
        expect { NoTaskTestUseCase.execute() }.to\
          raise_error(ActionLogic::InvalidUseCaseError)
      end
    end

    describe "around validations" do
      describe "required attributes and type validation" do
        it "does not raise error if context has required keys and values are of the correct type" do
          expect { ValidateAroundTestUseCase.execute(Constants::VALID_ATTRIBUTES) }.to_not raise_error
        end

        it "doesn't raise error if context is missing required keys" do
          expect { ValidateAroundTestUseCase.execute() }.to_not\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "doesn't raise error if context has required keys but values are not of correct type" do
          expect { ValidateAroundTestUseCase.execute(Constants::INVALID_ATTRIBUTES) }.to_not\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "required attributes and type validation with bang" do
        it "does not raise error if context has required keys and values are of the correct type" do
          expect { ValidateAroundTestUseCaseWithBang.execute(Constants::VALID_ATTRIBUTES) }.to_not raise_error
        end

        it "raises error if context is missing required keys" do
          expect { ValidateAroundTestUseCaseWithBang.execute() }.to\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "raises error if context has required keys but values are not of correct type" do
          expect { ValidateAroundTestUseCaseWithBang.execute(Constants::INVALID_ATTRIBUTES) }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "custom types" do
        it "allows validation against custom defined types" do
          expect { ValidateAroundCustomTypeTestUseCase.execute(:custom_type => CustomType1.new) }.to_not raise_error
        end

        it "doesn't raise error if context has custom type attribute but value is not correct custom type" do
          expect { ValidateAroundCustomTypeTestUseCase.execute(:custom_type => CustomType2.new) }.to_not\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "custom types with bang" do
        it "allows validation against custom defined types" do
          expect { ValidateAroundCustomTypeTestUseCaseWithBang.execute(:custom_type => CustomType1.new) }.to_not raise_error
        end

        it "raises error if context has custom type attribute but value is not correct custom type" do
          expect { ValidateAroundCustomTypeTestUseCaseWithBang.execute(:custom_type => CustomType2.new) }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "presence" do
        it "validates presence if presence is specified" do
          expect { ValidateAroundPresenceTestUseCase.execute(:integer_test => 1) }.to_not raise_error
        end

        it "doesn't raise error if context has required key but value is not defined when validation requires presence" do
          expect { ValidateAroundPresenceTestUseCase.execute(:integer_test => nil) }.to_not\
            raise_error(ActionLogic::PresenceError)
        end
      end

      describe "presence with bang" do
        it "validates presence if presence is specified" do
          expect { ValidateAroundPresenceTestUseCaseWithBang.execute(:integer_test => 1) }.to_not raise_error
        end

        it "raises error if context has required key but value is not defined when validation requires presence" do
          expect { ValidateAroundPresenceTestUseCaseWithBang.execute(:integer_test => nil) }.to\
            raise_error(ActionLogic::PresenceError)
        end
      end

      describe "custom presence" do
        it "allows custom presence validation if custom presence is defined" do
          expect { ValidateAroundCustomPresenceTestUseCase.execute(:array_test => [1]) }.to_not raise_error
        end

        it "doesn't raise error when custom presence validation is not satisfied" do
          expect { ValidateAroundCustomPresenceTestUseCase.execute(:array_test => []) }.to_not\
            raise_error(ActionLogic::PresenceError)
        end

        it "raises error if custom presence validation is not supported" do
          expect { ValidateAroundUnrecognizablePresenceTestUseCase.execute(:integer_test => 1) }.to\
            raise_error(ActionLogic::UnrecognizablePresenceValidatorError)
        end
      end

      describe "custom presence with bang" do
        it "allows custom presence validation if custom presence is defined" do
          expect { ValidateAroundCustomPresenceTestUseCaseWithBang.execute(:array_test => [1]) }.to_not raise_error
        end

        it "raises error when custom presence validation is not satisfied" do
          expect { ValidateAroundCustomPresenceTestUseCaseWithBang.execute(:array_test => []) }.to\
            raise_error(ActionLogic::PresenceError)
        end

        it "raises error if custom presence validation is not supported" do
          expect { ValidateAroundUnrecognizablePresenceTestUseCaseWithBang.execute(:integer_test => 1) }.to\
            raise_error(ActionLogic::UnrecognizablePresenceValidatorError)
        end
      end
    end

    describe "before validations" do
      describe "required attributes and type validation with bang" do
        it "does not raise error if context has required keys and values are of the correct type" do
          expect { ValidateBeforeTestUseCaseWithBang.execute(Constants::VALID_ATTRIBUTES) }.to_not raise_error
        end

        it "raises error if context is missing required keys" do
          expect { ValidateBeforeTestUseCaseWithBang.execute() }.to\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "raises error if context has required key but is not of correct type" do
          expect { ValidateBeforeTestUseCaseWithBang.execute(Constants::INVALID_ATTRIBUTES) }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "required attributes and type validation" do
        it "does not raise error if context has required keys and values are of the correct type" do
          expect { ValidateBeforeTestUseCase.execute(Constants::VALID_ATTRIBUTES) }.to_not raise_error
        end

        it "doesn't raise error if context is missing required keys" do
          expect { ValidateBeforeTestUseCase.execute() }.to_not\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "raises error if context has required key but is not of correct type" do
          expect { ValidateBeforeTestUseCase.execute(Constants::INVALID_ATTRIBUTES) }.to_not\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end


      describe "custom types" do
        it "allows validation against custom defined types" do
          expect { ValidateBeforeCustomTypeTestUseCaseWithBang.execute(Constants::CUSTOM_TYPE_ATTRIBUTES1) }.to_not raise_error
        end

        it "raises error if context has custom type attribute but value is not correct custom type" do
          expect { ValidateBeforeCustomTypeTestUseCaseWithBang.execute(Constants::CUSTOM_TYPE_ATTRIBUTES2) }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "presence" do
        it "validates presence if presence is specified" do
          expect { ValidateBeforePresenceTestUseCaseWithBang.execute(:integer_test => 1) }.to_not raise_error
        end

        it "raises error if context has required key but value is not defined when validation requires presence" do
          expect { ValidateBeforePresenceTestUseCaseWithBang.execute(:integer_test => nil) }.to\
            raise_error(ActionLogic::PresenceError)
        end
      end

      describe "custom presence" do
        it "allows custom presence validation if custom presence is defined" do
          expect { ValidateBeforeCustomPresenceTestUseCaseWithBang.execute(:array_test => [1]) }.to_not raise_error
        end

        it "raises error if custom presence validation is not satisfied" do
          expect { ValidateBeforeCustomPresenceTestUseCaseWithBang.execute(:array_test => []) }.to\
            raise_error(ActionLogic::PresenceError)
        end

        it "raises error if custom presence validation is not supported" do
          expect { ValidateBeforeUnrecognizablePresenceTestUseCaseWithBang.execute(:integer_test => 1) }.to\
            raise_error(ActionLogic::UnrecognizablePresenceValidatorError)
        end
      end
    end

    describe "after validations" do
      describe "required attributes and type validation" do
        it "does not raise error if the task sets all required keys and values are of the correct type" do
          expect { ValidateAfterTestUseCase.execute() }.to_not raise_error
        end

        it "raises error if task does not provide the necessary keys" do
          expect { ValidateAfterMissingAttributesTestUseCase.execute() }.to\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "raises error if task has required key but is not of correct type" do
          expect { ValidateAfterInvalidTypeTestUseCase.execute() }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "custom types" do
        it "allows validation against custom defined types" do
          expect { ValidateAfterCustomTypeTestUseCase.execute() }.to_not raise_error
        end

        it "raises error if context has custom type attribute but value is not correct custom type" do
          expect { ValidateAfterInvalidCustomTypeTestUseCase.execute() }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "presence" do
        it "validates presence if presence is specified" do
          expect { ValidateAfterPresenceTestUseCase.execute() }.to_not raise_error
        end

        it "raises error if context has required key but value is not defined when validation requires presence" do
          expect { ValidateAfterInvalidPresenceTestUseCase.execute() }.to\
            raise_error(ActionLogic::PresenceError)
        end
      end

      describe "custom presence" do
        it "allows custom presence validation if custom presence is defined" do
          expect { ValidateAfterCustomPresenceTestUseCase.execute() }.to_not raise_error
        end

        it "raises error if custom presence validation is not satisfied" do
          expect { ValidateAfterInvalidCustomPresenceTestUseCase.execute() }.to\
            raise_error(ActionLogic::PresenceError)
        end

        it "raises error if custom presence validation is not supported" do
          expect { ValidateAfterUnrecognizablePresenceTestUseCase.execute() }.to\
            raise_error(ActionLogic::UnrecognizablePresenceValidatorError)
        end
      end
    end

    describe "fail!" do
      it "returns the context with the correct status and failure message" do
        result = FailureTestUseCase.execute()

        expect(result.status).to eq(:failure)
        expect(result.message).to eq(Constants::FAILURE_MESSAGE)
      end

      it "stops execution of tasks after a task fails the context" do
        result = FailureTestUseCase.execute()

        expect(result.first).to eq("first")
        expect(result.second).to eq("second")
        expect(result.third).to be_nil
      end
    end

    describe "halt!" do
      it "returns the context with the correct status and halt message" do
        result = HaltTestUseCase.execute()

        expect(result.status).to eq(:halted)
        expect(result.message).to eq(Constants::HALT_MESSAGE)
      end

      it "stops execution of tasks after a task halts the context" do
        result = HaltTestUseCase.execute()

        expect(result.first).to eq("first")
        expect(result.second).to eq("second")
        expect(result.third).to be_nil
      end
    end

    describe "multiple use cases" do
      it "does not persist attributes set on contexts from different use cases" do
        result = HaltTestUseCase.execute()

        expect(result.first).to eq("first")
        expect(result.second).to eq("second")
        expect(result.third).to be_nil
        expect(result.status).to eq(:halted)

        result2 = ValidateAfterPresenceTestUseCase.execute()

        expect(result2.first).to be_nil
        expect(result2.second).to be_nil
        expect(result2.integer_test).to eq(1)
        expect(result2.success?).to be_truthy
      end
    end
  end
end
