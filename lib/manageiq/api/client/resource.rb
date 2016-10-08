module ManageIQ
  module API
    class Client
      class Resource
        include ActionMixin

        CUSTOM_INSPECT_EXCLUSIONS = [:@collection].freeze
        include CustomInspectMixin

        def self.subclass(name)
          name = name.classify

          if const_defined?(name, false)
            const_get(name, false)
          else
            const_set(name, Class.new(self))
          end
        end

        attr_reader :attributes
        attr_reader :collection
        attr_reader :actions

        delegate :client, :to => :collection

        def initialize(collection, resource_hash)
          raise "Cannot instantiate a Resource directly" if instance_of?(Resource)
          @collection = collection
          @attributes = resource_hash.except("actions")
          add_href
          fetch_actions(resource_hash)
        end

        private

        def method_missing(sym, *args, &block)
          reload_actions unless actions_present?
          if attributes.key?(sym.to_s)
            attributes[sym.to_s]
          elsif action_defined?(sym)
            exec_action(sym, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(sym, *_)
          attributes.key?(sym.to_s) || action_defined?(sym) || super
        end

        def exec_action(name, args = {}, &block)
          raise "Action #{name} parameters must be a hash" if !args.kind_of?(Hash)
          action = find_action(name)
          res = client.send(action.method, URI(action.href)) do
            body = { "action" => action.name }
            resource = args.dup
            resource.merge!(block.call) if block
            resource.present? ? body.merge("resource" => resource) : body
          end
          action_result(res)
        end

        # Let's add href's here if not yet defined by the server
        def add_href
          return if attributes.key?("href")
          return unless attributes.key?("id")
          attributes["href"] = client.connection.api_path("#{collection.name}/#{attributes['id']}")
        end

        def reload_actions
          return unless attributes.key?("href")
          resource_hash = client.get(attributes["href"])
          @attributes = resource_hash.except("actions")
          fetch_actions(resource_hash)
        end
      end
    end
  end
end
