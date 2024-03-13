module ManageIQ
  module API
    class Client
      class Error
        attr_reader :status
        attr_reader :kind
        attr_reader :message
        attr_reader :klass

        def initialize(status = 0, json_response = {})
          update(status, json_response)
        end

        def clear
          update(0)
        end

        def update(status, json_response = {})
          @status = status
          @kind, @message, @klass = nil
          error = json_response["error"]
          if status >= 400 && (!error.nil? && !error.empty?)
            if error.kind_of?(Hash)
              @kind, @message, @klass = error.values_at("kind", "message", "klass")
            else
              @message = error
            end
          end
        end
      end
    end
  end
end
