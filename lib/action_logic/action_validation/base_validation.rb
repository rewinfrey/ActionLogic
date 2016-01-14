module ActionLogic
  module ActionValidation
    class BaseValidation
      def self.error_message_format(error_string)
        "context: #{self.class} message: #{error_string}"
      end
    end
  end
end
