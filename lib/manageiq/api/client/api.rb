module ManageIQ
  module API
    class Client
      class API
        attr_accessor :name
        attr_accessor :description
        attr_accessor :version
        attr_accessor :versions

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
