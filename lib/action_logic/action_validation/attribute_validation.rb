require 'action_logic/errors'
require 'action_logic/action_validation/base_validation'

module ActionLogic
  module ActionValidation
    class AttributeValidation < BaseValidation

      def self.validate!(validation_rules, context)
        tmp_rules = validation_rules.clone
        raise_exception = tmp_rules.delete(:raise_action_logic_exception)
        existing_attributes = context.to_h.keys
        expected_attributes = tmp_rules.keys || []
        missing_attributes  = expected_attributes - existing_attributes

        if raise_exception
          raise ActionLogic::MissingAttributeError.new(error_message_format(missing_attributes.join(", ") + " attributes are missing")) if missing_attributes.any?
        end
      end
    end
  end
end
