require_relative "mixins/action_mixin"

module ManageIQ
  module API
    module Client
      class Collection
        include ActionMixin

        attr_accessor :name
        attr_accessor :href
        attr_accessor :description
        attr_accessor :server

        def initialize(server, collection_spec)
          @server      = server
          @name        = collection_spec["name"]
          @href        = collection_spec["href"]
          @description = collection_spec["description"]
          clear_actions
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
