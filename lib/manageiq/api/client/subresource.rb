module ManageIQ
  module API
    class Client
      class Subresource
        include ManageIQ::API::ResourceActionMixin

        CUSTOM_INSPECT_EXCLUSIONS = [:@resource].freeze
        include ManageIQ::API::CustomInspectMixin

        def self.subclass(name)
          name = name.classify

          if const_defined?(name, false)
            const_get(name, false)
          else
            const_set(name, Class.new(self))
          end
        end

        attr_reader :attributes
        attr_reader :subcollection
        attr_reader :actions

        delegate :client, :to => :resource
        delegate :resource, :to => :subcollection

        def initialize(subcollection, resource_hash)
          raise "Cannot instantiate a Subresource directly" if instance_of?(Subresource)
          @subcollection = subcollection
          @attributes = resource_hash.except("actions")
          add_href
          fetch_actions(resource_hash)
        end

        def [](attr)
          attr_str = attr.to_s
          attributes[attr_str] if attributes.key?(attr_str)
        end

        private

        def method_missing(sym, *args, &block)
          return attributes[sym.to_s] if attributes.key?(sym.to_s)
          reload_actions unless actions_present?
          if action_defined?(sym)
            exec_action(sym, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(sym, *_)
          attributes.key?(sym.to_s) || action_defined?(sym) || super
        end

        # Let's add href's here if not yet defined by the server
        def add_href
          return if attributes.key?("href")
          return unless attributes.key?("id")
          attributes["href"] = "#{resource.href}/#{self.class.name}/#{attributes['id']}"
        end
      end
    end
  end
end
