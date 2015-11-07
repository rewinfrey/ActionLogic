module ActionLogic
  class MissingAttributeError < StandardError; end
  class AttributeTypeError < StandardError; end
  class PresenceError < StandardError; end
  class UnrecognizablePresenceValidatorError < StandardError; end
end
