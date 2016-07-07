require "active_support"
require "active_support/core_ext"
require "faraday"
require "faraday_middleware"
require "json"

require "manageiq/api/client/version"
require "manageiq/api/client/authentication"
require "manageiq/api/client/connection"
require "manageiq/api/client/server"

module ManageIQ
  module API
    module Client
      def new(options = {})
        Connection.new(options)
      end
      module_function :new
    end
  end
end
