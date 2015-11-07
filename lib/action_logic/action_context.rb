require 'ostruct'

module ActionLogic
  class ActionContext < OpenStruct
    SUCCESS = :success
    FAILURE = :failure
    HALTED  = :halted

    def initialize(params = {})
      params[:status] ||= SUCCESS
      super(params)
    end

    def update!(status, message)
      self.status = status
      self.message = message
    end

    def fail!(message = "")
      update!(FAILURE, message)
    end

    def halt!(message = "")
      update!(HALTED, message)
    end

    def success?
      self.status == SUCCESS
    end

    def failure?
      self.status == FAILURE
    end

    def halted?
      self.status == HALTED
    end
  end
end
