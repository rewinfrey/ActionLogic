require 'action_logic/action_validation/attribute_validation'
require 'action_logic/action_validation/errors'
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

      def validates_before!(args)
        @validates_before_bang = args
      end

      def validates_after!(args)
        @validates_after_bang = args
      end

      def validates_around!(args)
        @validates_around_bang = args
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

      def get_validates_before!
        @validates_before_bang ||= {}
      end

      def get_validates_after!
        @validates_after_bang ||= {}
      end

      def get_validates_around!
        @validates_around_bang ||= {}
      end
    end

    def validation_types
      [AttributeValidation,
       TypeValidation,
       PresenceValidation]
    end

    def validate(validation, validation_rules)
      return if validation_rules.empty?
      validation.validate(validation_rules, context)
    end

    def validations(validation_order)
      case validation_order
      when :before then validation_types.each { |validation| validate(validation, @before_validation_rules) }
      when :after  then validation_types.each { |validation| validate(validation, @after_validation_rules) }
      when :around then validation_types.each { |validation| validate(validation, @around_validation_rules) }
      end
    end

    def set_validation_rules
      @before_validation_rules ||= self.class.get_validates_before
      @after_validation_rules  ||= self.class.get_validates_after
      @around_validation_rules ||= self.class.get_validates_around
    end

    def validate!(validation, validation_rules)
      return if validation_rules.empty?
      validation.validate!(validation_rules, context)
    end

    def validations!(validation_order)
      case validation_order
      when :before! then validation_types.each { |validation| validate!(validation, @before_validation_bang_rules) }
      when :after!  then validation_types.each { |validation| validate!(validation, @after_validation_bang_rules) }
      when :around! then validation_types.each { |validation| validate!(validation, @around_validation_bang_rules) }
      end
    end

    def set_validation_bang_rules
      @before_validation_bang_rules ||= self.class.get_validates_before!
      @after_validation_bang_rules  ||= self.class.get_validates_after!
      @around_validation_bang_rules ||= self.class.get_validates_around!
    end
  end
end
