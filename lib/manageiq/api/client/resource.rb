require_relative "mixins/action_mixin"

module ManageIQ
  module API
    module Client
      class Resource
        include ActionMixin

        attr_accessor :collection

        delegate :server, :to => :@collection

        def initialize(collection)
          @collection = collection
        end

        def self.new_subclass(name)
          klass_name = name.classify

          if ManageIQ::API::Client::Resource.const_defined?(klass_name)
            ManageIQ::API::Client::Resource.const_get(klass_name)
          else
            klass = Class.new(ManageIQ::API::Client::Resource) do
              attr_accessor :data

              def initialize(collection, resource_hash)
                @data = resource_hash.except("actions")
                fetch_actions(resource_hash)
                super(collection)
              end
            end

            ManageIQ::API::Client::Resource.const_set(klass_name, klass)
            klass
          end
        end
      end
    end
  end
end
