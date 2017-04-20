require 'action_logic/errors'
require 'action_logic/action_validation/base_validation'

module ActionLogic
  module ActionValidation
    class TypeValidation < BaseValidation

      def self.validate!(validation_rules, context)
        return unless validation_rules.values.find { |expected_validation| expected_validation[:type] }

        type_errors = validation_rules.reduce([]) do |collection, (expected_attribute, expected_validation)|
          next unless expected_validation[:type]

          if context.to_h[expected_attribute].class != expected_validation[:type]
            collection << "Attribute: #{expected_attribute} with value: #{context.to_h[expected_attribute]} was expected to be of type #{expected_validation[:type]} but is #{context.to_h[expected_attribute].class}"
          end
          collection
        end

        raise ActionLogic::AttributeTypeError.new(error_message_format(type_errors.join(", "))) if type_errors.any?
      end

      def self.validate(validation_rules, context)
        return unless validation_rules.values.find { |expected_validation| expected_validation[:type] }

        validation_rules.reduce([]) do |collection, (expected_attribute, expected_validation)|
          next unless expected_validation[:type]

          if context.to_h[expected_attribute].class != expected_validation[:type]
            context.errors.messages[expected_attribute] = "Value expected to be of type #{expected_validation[:type]} but is #{context.to_h[expected_attribute].class}"
          end
          collection
        end
      end
    end
  end
end
