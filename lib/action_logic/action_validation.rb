require 'action_logic/errors'

module ActionLogic
  module ActionValidation

    module ClassMethods
      def validates_before(args)
        @validates_before = args
      end

      def validates_after(args)
        @validates_after = args
      end

      def validates_around(args)
        @validates_around = args
      end

      def get_validates_before
        @validates_before ||= {}
      end

      def get_validates_after
        @validates_after ||= {}
      end

      def get_validates_around
        @validates_around ||= {}
      end
    end

    def validations
      [:validate_attributes!,
       :validate_types!,
       :validate_presence!]
    end

    def validate!(validation, validation_rules)
      return if validation_rules.empty?
      send(validation, validation_rules)
    end

    def validations!(validation_order)
      case validation_order
      when :before then validations.each { |validation| validate!(validation, @before_validation_rules) }
      when :after  then validations.each { |validation| validate!(validation, @after_validation_rules) }
      when :around then validations.each { |validation| validate!(validation, @around_validation_rules) }
      end
    end

    def set_validation_rules
      @before_validation_rules ||= self.class.get_validates_before
      @after_validation_rules  ||= self.class.get_validates_after
      @around_validation_rules ||= self.class.get_validates_around
    end

    def validate_attributes!(validations)
      existing_attributes = context.to_h.keys
      expected_attributes = validations.keys || []
      missing_attributes  = expected_attributes - existing_attributes

      raise ActionLogic::MissingAttributeError.new(error_message_format(missing_attributes.join(", ") + " attributes are missing")) if missing_attributes.any?
    end

    def validate_types!(validations)
      return unless validations.values.find { |expected_validation| expected_validation[:type] }

      type_errors = validations.reduce([]) do |collection, (expected_attribute, expected_validation)|
        next unless expected_validation[:type]

        if context.to_h[expected_attribute].class != expected_validation[:type]
          collection << "Attribute: #{expected_attribute} with value: #{context.to_h[expected_attribute]} was expected to be of type #{expected_validation[:type]} but is #{context.to_h[expected_attribute].class}"
        end
        collection
      end

      raise ActionLogic::AttributeTypeError.new(error_message_format(type_errors.join(", "))) if type_errors.any?
    end

    def validate_presence!(validations)
      return unless validations.values.find { |expected_validation| expected_validation[:presence] }

      presence_errors = validations.reduce([]) do |collection, (expected_attribute, expected_validation)|
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

    def error_message_format(error_string)
      "context: #{self.class} message: #{error_string}"
    end
  end
end
