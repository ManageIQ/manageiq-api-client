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
          klass = ManageIQ::API::Client::Resource.subclass(name)
          result_hash["resources"].collect do |resource_hash|
            klass.new(self, resource_hash)
          end
        end

        def self.subclass(name)
          klass_name = name.camelize

          if ManageIQ::API::Client::Collection.const_defined?(klass_name)
            ManageIQ::API::Client::Collection.const_get(klass_name)
          else
            klass = Class.new(ManageIQ::API::Client::Collection) do
              attr_accessor :name
              attr_accessor :href
              attr_accessor :description
              attr_accessor :actions

              def initialize(server, collection_spec)
                @name        = collection_spec["name"]
                @href        = collection_spec["href"]
                @description = collection_spec["description"]
                clear_actions
                super(server)
              end
            end

            ManageIQ::API::Client::Collection.const_set(klass_name, klass)
          end
        end
      end
    end
  end
end
