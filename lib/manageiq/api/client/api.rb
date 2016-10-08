module ManageIQ
  module API
    class Client
      class API
        attr_reader :name
        attr_reader :description
        attr_reader :version
        attr_reader :versions

        def initialize(entrypoint)
          @name, @description, @version = entrypoint.values_at("name", "description", "version")
          @versions = entrypoint["versions"].collect do |version_spec|
            ManageIQ::API::Client::ApiVersion.new(version_spec)
          end
        end
      end
    end
  end
end
