require 'pp'
require 'active_logic/errors'

module ActiveLogic
  module ActiveTask
    def validates_before(args)
      @validates_before = args
    end

    def validates_after(args)
      @validates_after = args
    end

    def make_context(params = {})
      ActiveContext.new(params)
    end

    def execute(params = {})
      context = make_context(params)
      default_validations
      validate_attributes!(context.to_h.keys, @validates_before.keys)
      validate_types!(context, @validates_before)
      self.new.(context)
      validate_attributes!(context.to_h.keys, @validates_after.keys)
      validate_types!(context, @validates_after)
      context
    end

    def validate_attributes!(existing_attributes, expected_attributes)
      existing_attributes = existing_attributes || []
      missing_attributes  = expected_attributes - existing_attributes
      raise ActiveLogic::MissingAttributeError.new(missing_attributes) if missing_attributes.any?
    end

    def validate_types!(existing_context, expected_attribute_types)
      type_errors = expected_attribute_types.reduce([]) do |collection, (expected_attribute, expected_value)|
        next unless expected_value[:type]

        if type_sym(existing_context.to_h[expected_attribute]) != expected_value[:type]
          collection << "Attribute: #{expected_attribute} with value: #{existing_context.to_h[expected_attribute]} was expected to be of type #{expected_value[:type]} but is #{type_sym(existing_context.to_h[expected_attribute])}"
        end
        collection
      end

      raise ActiveLogic::AttributeTypeError.new(type_errors) if type_errors.any?
    end

    def type_sym(value)
      case value.class.name.downcase.to_sym
      when :fixnum     then :integer
      when :falseclass then :boolean
      when :trueclass  then :boolean
      else
        value.class.name.downcase.to_sym
      end
    end

    def default_validations
      @validates_before ||= {}
      @validates_after  ||= {}
    end
  end
end
