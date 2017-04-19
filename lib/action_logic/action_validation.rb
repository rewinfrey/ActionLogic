require 'action_logic/action_validation/attribute_validation'
require 'action_logic/action_validation/presence_validation'
require 'action_logic/action_validation/type_validation'

module ActionLogic
  module ActionValidation
    module ClassMethods
      def validates_before(args)
        @validates_before = args.merge(raise_action_logic_exception: true)
      end

      def validates_after(args)
        @validates_after = args.merge(raise_action_logic_exception: true)
      end

      def validates_around!(args)
        @validates_around = args.merge(raise_action_logic_exception: true)
      end

      def validates_around(args)
        @validates_around = args.merge(raise_action_logic_exception: false)
      end

      def get_validates_before
        @validates_before ||= { raise_action_logic_exception: true }
      end

      def get_validates_after
        @validates_after ||= { raise_action_logic_exception: true }
      end

      def get_validates_around
        @validates_around ||= { raise_action_logic_exception: true }
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
