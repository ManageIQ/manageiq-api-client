module ManageIQ
  module API
    module Client
      class Error
        attr_accessor :status
        attr_accessor :kind
        attr_accessor :message
        attr_accessor :klass

        def initialize(status = 0, json_response = {})
          update(status, json_response)
        end

        def clear
          update(0)
        end

        def update(status, json_response = {})
          @status = status
          @kind, @message, @klass = nil
          error_hash = json_response["error"]
          if status >= 400 && error_hash.present?
            @kind    = error_hash["kind"]
            @message = error_hash["message"]
            @klass   = error_hash["klass"]
          end
        end
      end
    end
  end
end
