require 'action_logic/errors'
require 'action_logic/action_validation/base_validation'

module ActionLogic
  module ActionValidation
    class PresenceValidation < BaseValidation

      def self.validate!(validation_rules, context)
        return unless validation_rules.values.find { |expected_validation| expected_validation[:presence] }
        errors = validation_rules.reduce([]) do |error_collection, (expected_attribute, expected_validation)|
          next unless expected_validation[:presence]
          error_collection << error_message(expected_attribute, expected_validation, context)
          error_collection
        end || []
        raise ActionLogic::PresenceError.new(errors) if errors.any?
      end

      def self.presence_errors(validation_rules, context)
        validation_rules.reduce([]) do |error_collection, (expected_attribute, expected_validation)|
          next unless expected_validation[:presence]
          error_collection << error_message(expected_attribute, expected_validation, context)
          error_collection
        end || []
      end

      def self.error_message(expected_attribute, expected_validation, context)
        case expected_validation[:presence]
        when TrueClass then "Attribute: #{expected_attribute} is missing value in context but presence validation was specified" unless context[expected_attribute]
        when Proc      then "Attribute: #{expected_attribute} is missing value in context but custom presence validation was specified" unless expected_validation[:presence].call(context[expected_attribute])
        else
          raise ActionLogic::UnrecognizablePresenceValidatorError.new(error_message_format("Presence validator: #{expected_validation[:presence]} is not a supported format"))
        end
      end

      def self.validate(validation_rules, context)
        return unless validation_rules.values.find { |expected_validation| expected_validation[:presence] }
        validation_rules.each do |(expected_attribute, expected_validation)|
          next unless expected_validation[:presence]
          context.errors.messages[expected_attribute] << "Missing value according to presence validation" if error?(expected_attribute, expected_validation, context)
        end
      end

      def self.error?(expected_attribute, expected_validation, context)
        case expected_validation[:presence]
        when TrueClass then false if context[expected_attribute]
        when Proc      then expected_validation[:presence].call(context[expected_attribute])
        else
          raise ActionLogic::UnrecognizablePresenceValidatorError.new(error_message_format("Presence validator: #{expected_validation[:presence]} is not a supported format"))
        end
      end
    end
  end
end
