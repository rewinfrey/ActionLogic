require 'spec_helper'
require 'action_logic'
require 'fixtures/coordinators'
require 'fixtures/custom_types'

module ActionLogic
  describe ActionCoordinator do
    it "knows its type" do
      expect(TestCoordinator1.__private__type).to eq(:coordinator)
    end

    context "no failures and no halts" do
      it "evaluates all use cases defined by the state transition plan" do
        result = TestCoordinator1.execute()

        expect(result.test_coordinator1).to be_truthy
        expect(result.test_use_case1).to be_truthy
        expect(result.test_task1).to be_truthy
        expect(result.test_use_case2).to be_truthy
        expect(result.test_task2).to be_truthy
        expect(result.test_use_case3).to be_truthy
        expect(result.test_task3).to be_truthy
      end
    end

    context "with halts" do
      it "evaluates all use cases defined by the state transition plan" do
        result = HaltedTestCoordinator1.execute()

        expect(result.halted_test_coordinator1).to be_truthy
        expect(result.halted_test_use_case1).to be_truthy
        expect(result.halted_test_task1).to be_truthy
        expect(result.test_use_case2).to be_truthy
        expect(result.test_task2).to be_truthy
        expect(result.test_use_case3).to be_truthy
        expect(result.test_task3).to be_truthy
      end
    end

    context "with failures" do
      it "evaluates all use cases defined by the state transition plan" do
        result = FailureTestCoordinator1.execute()

        expect(result.failure_test_coordinator1).to be_truthy
        expect(result.failure_test_use_case1).to be_truthy
        expect(result.failure_test_task1).to be_truthy
        expect(result.test_use_case2).to be_truthy
        expect(result.test_task2).to be_truthy
        expect(result.test_use_case3).to be_truthy
        expect(result.test_task3).to be_truthy
      end
    end

    describe "before validations" do
      describe "required attributes and type validation" do
        it "does not raise error if context has required keys and values are of the correct type" do
          expect { ValidateBeforeTestCoordinator.execute(Constants::VALID_ATTRIBUTES) }.to_not raise_error
        end

        it "raises error if context is missing required keys" do
          expect { ValidateBeforeTestCoordinator.execute() }.to\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "raises error if context has required key but is not of correct type" do
          expect { ValidateBeforeTestCoordinator.execute(Constants::INVALID_ATTRIBUTES) }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "custom types" do
        it "allows validation against custom defined types" do
          expect { ValidateBeforeCustomTypeTestCoordinator.execute(Constants::CUSTOM_TYPE_ATTRIBUTES1) }.to_not raise_error
        end

        it "raises error if context has custom type attribute but value is not correct custom type" do
          expect { ValidateBeforeCustomTypeTestCoordinator.execute(Constants::CUSTOM_TYPE_ATTRIBUTES2) }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "presence" do
        it "validates presence if presence is specified" do
          expect { ValidateBeforePresenceTestCoordinator.execute(:integer_test => 1) }.to_not raise_error
        end

        it "raises error if context has required key but value is not defined when validation requires presence" do
          expect { ValidateBeforePresenceTestCoordinator.execute(:integer_test => nil) }.to\
            raise_error(ActionLogic::PresenceError)
        end
      end

      describe "custom presence" do
        it "allows custom presence validation if custom presence is defined" do
          expect { ValidateBeforeCustomPresenceTestCoordinator.execute(:array_test => [1]) }.to_not raise_error
        end

        it "raises error if custom presence validation is not satisfied" do
          expect { ValidateBeforeCustomPresenceTestCoordinator.execute(:array_test => []) }.to\
            raise_error(ActionLogic::PresenceError)
        end

        it "raises error if custom presence validation is not supported" do
          expect { ValidateBeforeUnrecognizablePresenceTestCoordinator.execute(:integer_test => 1) }.to\
            raise_error(ActionLogic::UnrecognizablePresenceValidatorError)
        end
      end
    end

    describe "after validations" do
      describe "required attributes and type validation" do
        it "does not raise error if the task sets all required keys and values are of the correct type" do
          expect { ValidateAfterTestCoordinator.execute() }.to_not raise_error
        end

        it "raises error if task does not provide the necessary keys" do
          expect { ValidateAfterMissingAttributesTestCoordinator.execute() }.to\
            raise_error(ActionLogic::MissingAttributeError)
        end

        it "raises error if task has required key but is not of correct type" do
          expect { ValidateAfterInvalidTypeTestCoordinator.execute() }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "custom types" do
        it "allows validation against custom defined types" do
          expect { ValidateAfterCustomTypeTestCoordinator.execute() }.to_not raise_error
        end

        it "raises error if context has custom type attribute but value is not correct custom type" do
          expect { ValidateAfterInvalidCustomTypeTestCoordinator.execute() }.to\
            raise_error(ActionLogic::AttributeTypeError)
        end
      end

      describe "presence" do
        it "validates presence if presence is specified" do
          expect { ValidateAfterPresenceTestCoordinator.execute() }.to_not raise_error
        end

        it "raises error if context has required key but value is not defined when validation requires presence" do
          expect { ValidateAfterInvalidPresenceTestCoordinator.execute() }.to\
            raise_error(ActionLogic::PresenceError)
        end
      end

      describe "custom presence" do
        it "allows custom presence validation if custom presence is defined" do
          expect { ValidateAfterCustomPresenceTestCoordinator.execute() }.to_not raise_error
        end

        it "raises error if custom presence validation is not satisfied" do
          expect { ValidateAfterInvalidCustomPresenceTestCoordinator.execute() }.to\
            raise_error(ActionLogic::PresenceError)
        end

        it "raises error if custom presence validation is not supported" do
          expect { ValidateAfterUnrecognizablePresenceTestCoordinator.execute() }.to\
            raise_error(ActionLogic::UnrecognizablePresenceValidatorError)
        end
      end
    end
  end
end
