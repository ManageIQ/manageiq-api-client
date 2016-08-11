module ManageIQ
  module API
    class Client
      class Resource
        include ActionMixin

        def initialize(*_args)
          raise "Cannot instantiate a #{self.class}"
        end

        def self.subclass(name)
          klass_name = name.classify

          if const_defined?(klass_name)
            const_get(klass_name)
          else
            klass = Class.new(self) do
              attr_accessor :data
              attr_accessor :collection

              delegate :client, :to => :@collection

              define_method("initialize") do |collection, resource_hash|
                @collection = collection
                @data = resource_hash.except("actions")
                fetch_actions(resource_hash)
              end

              define_method("method_missing") do |sym|
                if data.key?(sym.to_s)
                  data[sym.to_s]
                else
                  raise NoMethodError, "undefined method `#{sym}' for #{self}"
                end
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
