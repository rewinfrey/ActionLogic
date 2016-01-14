require 'action_logic/errors'
require 'action_logic/action_validation/base_validation'

module ActionLogic
  module ActionValidation
    class PresenceValidation < BaseValidation

      def self.validate!(validation_rules, context)
        return unless validation_rules.values.find { |expected_validation| expected_validation[:presence] }

        presence_errors = validation_rules.reduce([]) do |collection, (expected_attribute, expected_validation)|
          next unless expected_validation[:presence]

          if expected_validation[:presence] == true
            collection << "Attribute: #{expected_attribute} is missing value in context but presence validation was specified" unless context[expected_attribute]
          elsif expected_validation[:presence].class == Proc
            collection << "Attribute: #{expected_attribute} is missing value in context but custom presence validation was specified" unless expected_validation[:presence].call(context[expected_attribute])
          else
            raise ActionLogic::UnrecognizablePresenceValidatorError.new(error_message_format("Presence validator: #{expected_validation[:presence]} is not a supported format"))
          end

          collection
        end || []

        raise ActionLogic::PresenceError.new(presence_errors) if presence_errors.any?
      end
    end
  end
end
