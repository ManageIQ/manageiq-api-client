module ManageIQ
  module API
    class Client
      class ActsAsArQuery
        include Enumerable
        attr_accessor :klass, :options

        SORT_ASC = "asc".freeze
        SORT_DESC = "desc".freeze

        def initialize(klass, opts = nil)
          @klass = klass
          @options = opts || {}
        end

        def where(*val)
          conditional(:where, val)
        end

        def not(*val)
          conditional(:not, val)
        end

        def order(*val)
          options[:order] ||= {}
          val.flatten.each do |sval|
            case sval
            when String
              sval.split(",").each do |value|
                sort_attr, sort_order = value.split(" ")
                options[:order][sort_attr.to_s] = sort_order || SORT_ASC
              end
            when Hash
              sval.each do |sort_attr, sort_order|
                options[:order][sort_attr.to_s] = sort_order
              end
            when Symbol
              options[:order][sval.to_s] = SORT_ASC
            end
          end
          self
        end

        def reorder(*val)
          order(val)
        end

        def reverse_order
          if options[:order].present?
            options[:order] = options[:order].keys.each_with_object({}) { |key, hash| hash[key.to_s] = SORT_DESC }
          end
          self
        end

        def except(*val)
          val.flatten.each do |key|
            options.delete(key)
          end
          self
        end

        # similar to except, difference being this persists across merges.
        def unscope(*val)
          val.flatten.each do |key|
            options[key] = nil
          end
          self
        end

        def only(*val)
          options.slice!(val)
          self
        end

        def offset(val)
          assign_arg :offset, val
        end

        def limit(val)
          assign_arg :limit, val
        end

        def select(*args)
          append_hash_arg :select, *args
        end

        def to_a
          @results ||= klass.ar_search(options)
        end

        def all
          self
        end

        def count(*_args)
          to_a.size
        end

        def first
          positional(:first)
        end

        def second
          positional(:second)
        end

        def third
          positional(:third)
        end

        def fourth
          positional(:fourth)
        end

        def fifth
          positional(:fifth)
        end

        def last
          positional(:last)
        end

        def ids
          # Change to using .collect(&:id) once PR# 23 is merged
          to_a.collect { |resource| resource.data["id"] }
        end

        delegate :size, :take, :each, :empty?, :presence, :to => :to_a

        private

        def positional(position)
          defined?(@results) ? @results.send(position) : to_a.send(position)
        end

        def conditional(symbol, *val)
          val = val.flatten
          val = val.first if val.size == 1 && val.first.kind_of?(Hash)
          old_value = options[symbol]
          if val.empty?
            # nop
          elsif old_value.blank?
            options[symbol] = val
          elsif old_value.kind_of?(Hash) && val.kind_of?(Hash)
            val.each_pair do |key, value|
              old_value[key] = if old_value[key]
                                 Array.wrap(old_value[key]) + Array.wrap(value)
                               else
                                 value
                               end
            end
          else
            raise ArgumentError,
                  "Need to support #{__callee__}(#{val.class.name}) with existing #{old_value.class.name}"
          end
          self
        end

        def append_hash_arg(symbol, *val)
          val = val.flatten
          if val.first.kind_of?(Hash)
            raise ArgumentError, "Need to support #{symbol}(#{val.class.name})"
          end
          options[symbol] = options[symbol] ? (options[symbol] + val) : val
          self
        end

        def assign_arg(symbol, val)
          options[symbol] = val
          self
        end
      end
    end
  end
end
