require_relative "mixins/action_mixin"

module ManageIQ
  module API
    module Client
      class Collection
        include ActionMixin

        attr_accessor :server

        def initialize(server)
          @server = server
        end

        def search(options = {})
          options[:expand] = (String(options[:expand]).split(",") | %w(resources)).join(",")
          result_hash = server.get(name, options)
          fetch_actions(result_hash)
          result_hash["resources"].collect do |resource_hash|
            ManageIQ::API::Client::Resource.new(self, resource_hash)
          end
        end
      end
    end
  end
end
