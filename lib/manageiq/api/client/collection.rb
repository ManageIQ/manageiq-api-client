module ManageIQ
  module API
    class Client
      class Collection
        include ActionMixin

        def initialize(*_args)
          raise "Cannot instantiate a #{self.class}"
        end

        def self.subclass(name)
          klass_name = name.camelize

          if const_defined?(klass_name, false)
            const_get(klass_name, false)
          else
            klass = Class.new(self) do
              attr_accessor :client

              attr_accessor :name
              attr_accessor :href
              attr_accessor :description
              attr_accessor :actions

              define_method("initialize") do |client, collection_spec|
                @client = client
                @name, @href, @description = collection_spec.values_at("name", "href", "description")
                clear_actions
              end

              define_method("search") do |options = {}|
                options[:expand] = (String(options[:expand]).split(",") | %w(resources)).join(",")
                options[:filter] = Array(options[:filter]) if options[:filter].is_a?(String)
                result_hash = client.get(name, options)
                fetch_actions(result_hash)
                klass = ManageIQ::API::Client::Resource.subclass(name)
                result_hash["resources"].collect do |resource_hash|
                  klass.new(self, resource_hash)
                end
              end
            end

            const_set(klass_name, klass)
          end
        end
      end
    end
  end
end
