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
                fetch_actions(resource_hash)
              end

              define_method("method_missing") do |sym, *args|
                data.key?(sym.to_s) ? data[sym.to_s] : super(sym, *args)
              end

              define_method("respond_to_missing?") do |sym, *args|
                data.key?(sym.to_s) || super(sym, *args)
              end
            end
            const_set(klass_name, klass)
            klass
          end
        end
      end
    end
  end
end
