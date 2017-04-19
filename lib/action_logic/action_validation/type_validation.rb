require 'action_logic/errors'
require 'action_logic/action_validation/base_validation'

module ActionLogic
  module ActionValidation
    class TypeValidation < BaseValidation

      def self.validate!(validation_rules, context)
        tmp_rules = validation_rules.clone
        raise_exception = tmp_rules.delete(:raise_action_logic_exception)
        return unless tmp_rules.values.find { |expected_validation| expected_validation[:type] }

        type_errors = tmp_rules.reduce([]) do |collection, (expected_attribute, expected_validation)|
          next unless expected_validation[:type]

          if context.to_h[expected_attribute].class != expected_validation[:type]
            collection << "Attribute: #{expected_attribute} with value: #{context.to_h[expected_attribute]} was expected to be of type #{expected_validation[:type]} but is #{context.to_h[expected_attribute].class}"
          end
          collection
        end

        if raise_exception
          raise ActionLogic::AttributeTypeError.new(error_message_format(type_errors.join(", "))) if type_errors.any?
        end
      end
    end
  end
end
