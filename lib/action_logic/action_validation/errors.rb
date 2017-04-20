module ActionLogic
  module ActionValidation
    class Errors
      attr_accessor :messages

      def initialize
        @messages = Hash.new { |messages, attribute| messages[attribute] = [] }
      end
    end
  end
end
