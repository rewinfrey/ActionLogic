require 'action_logic/errors'
require 'action_logic/action_validation/base_validation'

module ActionLogic
  module ActionValidation
    class AttributeValidation < BaseValidation

      def self.validate!(validation_rules, context)
        existing_attributes = context.to_h.keys
        expected_attributes = validation_rules.keys || []
        missing_attributes  = expected_attributes - existing_attributes

        raise ActionLogic::MissingAttributeError.new(error_message_format(missing_attributes.join(", ") + " attributes are missing")) if missing_attributes.any?
      end
    end
  end
end
