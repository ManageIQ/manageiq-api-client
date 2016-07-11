module ManageIQ
  module API
    module Client
      class Collection
        attr_accessor :name
        attr_accessor :href
        attr_accessor :description
        attr_accessor :actions
        attr_accessor :server

        def initialize(server, collection_spec)
          @server      = server
          @name        = collection_spec["name"]
          @href        = collection_spec["href"]
          @description = collection_spec["description"]
          @actions     = []
        end

        def actions=(action_array)
          @actions = action_array.blank? ? [] : action_array
        end

        def add_action(action)
          @actions << action
        end

        def search(options = {})
          options[:expand] = (String(options[:expand]).split(",") | %w(resources)).join(",")
          result_hash = server.get(name, options)
          @actions = Array(result_hash["actions"]).collect { |action| ManageIQ::API::Client::Action.new(action) }
          result_hash["resources"].collect do |resource_hash|
            ManageIQ::API::Client::Resource.new(self, resource_hash)
          end
        end
      end
    end
  end
end
