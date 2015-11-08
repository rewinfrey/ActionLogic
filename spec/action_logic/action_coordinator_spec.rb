require 'spec_helper'
require 'action_logic'
require 'fixtures/coordinators'
require 'fixtures/custom_types'

module ActionLogic
  describe ActionCoordinator do
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
  end
end
