module ManageIQ
  module API
    module Client
      class ServerApi
        attr_accessor :name
        attr_accessor :description
        attr_accessor :version
        attr_accessor :versions

        def initialize(entrypoint)
          @name        = entrypoint["name"]
          @description = entrypoint["description"]
          @version     = entrypoint["version"]
          @versions    = entrypoint["versions"].collect do |version_spec|
            ManageIQ::API::Client::ApiVersion.new(version_spec)
          end
        end
      end
    end
  end
end
