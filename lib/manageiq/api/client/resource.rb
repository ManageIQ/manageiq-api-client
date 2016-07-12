module ManageIQ
  module API
    module Client
      class Resource
        include ActionMixin

        attr_accessor :collection
        attr_accessor :data

        delegate :server, :to => :@collection

        def initialize(collection, resource_hash)
          @collection = collection
          @data       = resource_hash.except("actions")
          fetch_actions(resource_hash)
        end
      end
    end
  end
end
