module ManageIQ
  module API
    module Client
      class Collection
        attr_accessor :name
        attr_accessor :href
        attr_accessor :description
        attr_accessor :actions

        def initialize(collection_spec)
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
      end
    end
  end
end
