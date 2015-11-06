require 'ostruct'

module ActionLogic
  class ActionContext < OpenStruct
    def initialize(params = {})
      params[:success] ||= true
      super(params)
    end

    def fail!(message = "")
      self.success = false
      update!(:failure, message)
    end

    def halt!(message = "")
      update!(:halted, message)
    end

    def update!(status, message)
      self.status = status
      self.message = message
    end

    def success?
      success
    end
  end
end
