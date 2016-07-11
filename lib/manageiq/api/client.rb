require "active_support"
require "active_support/core_ext"
require "faraday"
require "faraday_middleware"
require "json"
require "more_core_extensions/all"

require "manageiq/api/client/action"
require "manageiq/api/client/api_version"
require "manageiq/api/client/authentication"
require "manageiq/api/client/collection"
require "manageiq/api/client/connection"
require "manageiq/api/client/error"
require "manageiq/api/client/identity"
require "manageiq/api/client/server"
require "manageiq/api/client/server_api"
require "manageiq/api/client/version"

module ManageIQ
  module API
    module Client
      def new(options = {})
        Server.new(options)
      end
      module_function :new
    end
  end
end
