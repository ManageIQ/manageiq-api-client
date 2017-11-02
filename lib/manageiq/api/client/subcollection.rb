module ManageIQ
  module API
    class Client
      class Subcollection
        include CollectionActionMixin
        include Enumerable
        include QueryableMixin

        CUSTOM_INSPECT_EXCLUSIONS = [:@resource].freeze
        include CustomInspectMixin

        attr_reader :name
        attr_reader :href
        attr_reader :resource

        delegate :client, :to => :resource

        def initialize(name, resource)
          @name, @resource, @href = name.to_s, resource, "#{resource.href}/#{name}"
          clear_actions
          result_hash = client.get(href, :hide => "resources")
          fetch_actions(result_hash)
        end

        def each(&block)
          all.each(&block)
        end

        def self.subclass(name)
          name = name.camelize

          if const_defined?(name, false)
            const_get(name, false)
          else
            const_set(name, Class.new(self))
          end
        end

        def get(options = {})
          options[:expand] = (String(options[:expand]).split(",") | %w(resources)).join(",")
          options[:filter] = Array(options[:filter]) if options[:filter].is_a?(String)
          result_hash = client.get(href, options)
          fetch_actions(result_hash)
          klass = ManageIQ::API::Client::Subresource.subclass(name)
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
