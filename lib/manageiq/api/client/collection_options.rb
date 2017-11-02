module ManageIQ
  module API
    class Client
      class CollectionOptions
        attr_reader :attributes
        attr_reader :virtual_attributes
        attr_reader :relationships
        attr_reader :subcollections
        attr_reader :data

        def initialize(options = {})
          @attributes, @virtual_attributes, @relationships, @subcollections, @data =
            options.values_at("attributes", "virtual_attributes", "relationships", "subcollections", "data")
        end
      end
    end
  end
end
