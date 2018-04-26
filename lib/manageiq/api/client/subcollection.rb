module ManageIQ
  module API
    class Client
      class Subcollection < Collection

        CUSTOM_INSPECT_EXCLUSIONS = [:@resource].freeze

        attr_reader :name
        attr_reader :href
        attr_reader :resource

        delegate :client, :to => :resource

        def initialize(name, resource)
          @name, @resource, @href = name.to_s, resource, "#{resource.href}/#{name}"
          clear_actions
          query_actions(href)
        end

        def get(options = {})
          options[:expand] = (String(options[:expand]).split(",") | %w(resources)).join(",")
          options[:filter] = Array(options[:filter]) if options[:filter].is_a?(String)
          result_hash = client.get(href, options)
          fetch_actions(result_hash)
          klass = ManageIQ::API::Client::Resource.subclass(name)
          result_hash["resources"].collect do |resource_hash|
            klass.new(self, resource_hash)
          end
        end

        private

        def method_missing(sym, *args, &block)
          if action_defined?(sym)
            exec_action(sym, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(sym, *_)
          action_defined?(sym) || super
        end
      end
    end
  end
end
