module ActionLogic
  # Thrown whenever an ActionTask, ActionUseCase or ActionCoordinator's context does not have a key defined for the attribute key in a validations block
  class MissingAttributeError < StandardError; end

  # Thrown whenever an ActionTask, ActionUseCase or ActionCoordinator's context has an attribute and value but the value's type is not the same as that
  # attributey's type specified in a validations block
  class AttributeTypeError < StandardError; end

  # Thrown whenever an ActionTask, ActionUseCase or ActionCoordinator's context has an attribute and value but the value definition of presence is not satisfied
  # for the value stored on the context
  class PresenceError < StandardError; end

  # Adding a custom presence definition is possible, but the presence validation will throw an error if the custom presence definition is not a Proc
  class UnrecognizablePresenceValidatorError < StandardError; end

  # ActionUseCases are invalid if they do not define any tasks
  class InvalidUseCaseError < StandardError; end
end
