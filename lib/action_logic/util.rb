module ActionLogic
  module Util

    def default_validations
      @validates_before ||= {}
      @validates_after  ||= {}
    end

    def validates_before(args)
      @validates_before = args
    end

    def validates_after(args)
      @validates_after = args
    end

    def validations
      [:validate_attributes!,
       :validate_types!,
       :validate_presence!]
    end

    def around(params, &blk)
      context = make_context(params)
      default_validations
      execution_context = self.new

      validations.each { |validation| self.send(validation, context, @validates_before) }

      begin
        context = blk.call(context, execution_context)
      rescue => e
        if execution_context.respond_to?(:error)
          execution_context.error(e, context)
        else
          raise e
        end
      end

      validations.each { |validation| self.send(validation, context, @validates_after) }

      context
    end

    def make_context(params = {})
      ActionContext.new(params)
    end

    def validate_attributes!(existing_context, validations)
      existing_attributes = existing_context.to_h.keys
      expected_attributes = validations.keys || []
      missing_attributes  = expected_attributes - existing_attributes

      raise ActionLogic::MissingAttributeError.new(missing_attributes) if missing_attributes.any?
    end

    def validate_types!(existing_context, validations)
      return unless validations.values.find { |expected_validation| expected_validation[:type] }

      type_errors = validations.reduce([]) do |collection, (expected_attribute, expected_validation)|
        next unless expected_validation[:type]

        if type_to_sym(existing_context.to_h[expected_attribute]) != expected_validation[:type]
          collection << "Attribute: #{expected_attribute} with value: #{existing_context.to_h[expected_attribute]} was expected to be of type #{expected_validation[:type]} but is #{type_to_sym(existing_context.to_h[expected_attribute])}"
        end
        collection
      end

      raise ActionLogic::AttributeTypeError.new(type_errors) if type_errors.any?
    end

    def validate_presence!(existing_context, validations)
      return unless validations.values.find { |expected_validation| expected_validation[:presence] }

      presence_errors = validations.reduce([]) do |collection, (expected_attribute, expected_validation)|
        next unless expected_validation[:presence]

        if expected_validation[:presence] == true
          collection << "Attribute: #{expected_attribute} is missing value in context but presence validation was specified" unless existing_context[expected_attribute]
        else
          collection << "Attribute: #{expected_attribute} is missing value in context but custom presence validation was specified" unless expected_validation[:presence].call(existing_context[expected_attribute])
        end

        collection
      end || []

      raise ActionLogic::PresenceError.new(presence_errors) if presence_errors.any?
    end

    def type_to_sym(value)
      case value.class.name.downcase.to_sym
      when :fixnum     then :integer
      when :falseclass then :boolean
      when :trueclass  then :boolean
      when :nilclass   then :nil
      else
        value.class.name.downcase.to_sym
      end
    end
  end
end
