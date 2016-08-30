module ManageIQ
  module API
    class Client
      class Resource
        include ActionMixin

        CUSTOM_INSPECT_EXCLUSIONS = [:@collection].freeze
        include CustomInspectMixin

        def initialize(*_args)
          raise "Cannot instantiate a #{self.class}"
        end

        def self.subclass(name)
          klass_name = name.classify

          if const_defined?(klass_name, false)
            const_get(klass_name, false)
          else
            klass = Class.new(self) do
              attr_accessor :data
              attr_accessor :collection
              attr_accessor :actions

              delegate :client, :to => :@collection

              define_method("initialize") do |collection, resource_hash|
                @collection = collection
                @data = resource_hash.except("actions")
                add_href
                fetch_actions(resource_hash)
              end

              define_method("method_missing") do |sym, *args, &block|
                reload_actions unless actions_present?
                if data.key?(sym.to_s)
                  data[sym.to_s]
                elsif action_defined?(sym)
                  exec_action(sym, *args, &block)
                else
                  super(sym, *args, &block)
                end
              end

              define_method("respond_to_missing?") do |sym, *args, &block|
                data.key?(sym.to_s) || action_defined?(sym) || super(sym, *args, &block)
              end
            end
            const_set(klass_name, klass)
            klass
          end
        end

        private

        def exec_action(name, args = {}, &block)
          raise "Action #{name} parameters must be a hash" if !args.kind_of?(Hash)
          action = find_action(name)
          res = client.send(action.method, URI(action.href)) do
            body = { "action" => action.name }
            resource = args.dup
            resource.merge!(yield(block)) if block
            resource.present? ? body.merge("resource" => resource) : body
          end
          action_result(res)
        end

        # Let's add href's here if not yet defined by the server
        def add_href
          return if data.key?("href")
          return unless data.key?("id")
          data["href"] = client.connection.api_path("#{collection.name}/#{data['id']}")
        end

        def reload_actions
          return unless data.key?("href")
          resource_hash = client.get(data["href"])
          @data = resource_hash.except("actions")
          fetch_actions(resource_hash)
        end
      end
    end
  end
end
