module ManageIQ
  module API
    class Client
      class Subresource
        include ManageIQ::API::Client::ResourceActionMixin

        CUSTOM_INSPECT_EXCLUSIONS = [:@resource].freeze
        include ManageIQ::API::Client::CustomInspectMixin

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
          reload_actions unless actions_present?
          if attributes.key?(sym.to_s)
            attributes[sym.to_s]
          elsif action_defined?(sym)
            exec_action(sym, *args, &block)
          elsif subcollection_defined?(sym)
            invoke_subcollection(sym)
          else
            super
          end
        end

        def subcollection_defined?(name)
          collection.options.subcollections.include?(name.to_s)
        end

        def respond_to_missing?(sym, *_)
          attributes.key?(sym.to_s) || action_defined?(sym) || subcollection_defined?(sym) || super
        end

        # Let's add href's here if not yet defined by the server
        def add_href
          return if attributes.key?("href")
          return unless attributes.key?("id")
          attributes["href"] = "#{resource.href}/#{self.class.name}/#{attributes['id']}"
        end

        def invoke_subcollection(name)
          @_subcollections ||= {}
          @_subcollections[name.to_s] ||= ManageIQ::API::Client::Subcollection.subclass(name.to_s).new(name.to_s, self)
        end
      end
    end
  end
end
