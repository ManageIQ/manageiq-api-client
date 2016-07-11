module ManageIQ
  module API
    module Client
      class Resource
        attr_accessor :collection
        attr_accessor :actions
        attr_accessor :data

        delegate :server, :to => :@collection

        def initialize(collection, resource_hash)
          @collection = collection
          @data       = resource_hash.except("actions")
          @actions    = Array(resource_hash["actions"]).collect { |action| ManageIQ::API::Client::Action.new(action) }
        end

        def actions=(action_array)
          @actions = action_array.blank? ? [] : action_array
        end

        def add_action(action)
          @actions << action
        end
      end
    end
  end
end
