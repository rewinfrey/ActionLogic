require 'action_logic/action_validation/attribute_validation'
require 'action_logic/action_validation/presence_validation'
require 'action_logic/action_validation/type_validation'

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

      def validates_around!(args)
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
      [AttributeValidation,
       TypeValidation,
       PresenceValidation]
    end

    def validate!(validation, validation_rules)
      return if validation_rules.empty?
      validation.validate!(validation_rules, context)
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
  end
end
