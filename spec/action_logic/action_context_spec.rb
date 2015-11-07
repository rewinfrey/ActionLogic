require 'spec_helper'
require 'action_logic'
require 'fixtures/constants'

module ActionLogic
  describe ActionContext do
    subject { ActionContext.new }

    describe "initialization" do
      it "sets a default success attribute on the context" do
        expect(subject.success).to be_truthy
      end
    end

    describe "success?" do
      it "returns true if the context is successful" do
        expect(subject.success?).to be_truthy
      end
    end

    describe "failing a context" do
      it "sets the context status as failed" do
        subject.fail!

        expect(subject.status).to eq(:failure)
      end

      it "does not require a message" do
        subject.fail!

        expect(subject.message).to be_empty
      end

      it "allows a custom failure message to be defined" do
        failure_message = Constants::FAILURE_MESSAGE
        subject.fail!(failure_message)

        expect(subject.message).to eq(failure_message)
      end

      it "sets success to false on the context" do
        subject.fail!

        expect(subject.success?).to be_falsey
      end
    end

    describe "halting a context" do
      it "sets the context status as halted" do
        subject.halt!

        expect(subject.status).to eq(:halted)
      end

      it "does not require a message" do
        subject.halt!

        expect(subject.message).to be_empty
      end

      it "allows a custom failure message to be defined" do
        halt_message  = Constants::HALT_MESSAGE
        subject.halt!(halt_message)

        expect(subject.message).to eq(halt_message)
      end

      it "does not alter success on the context" do
        subject.halt!

        expect(subject.success).to be_truthy
      end
    end
  end
end
