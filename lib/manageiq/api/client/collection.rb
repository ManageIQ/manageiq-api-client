module ManageIQ
  module API
    class Client
      class Collection
        include ActionMixin
        include Enumerable
        include QueryRelation::Queryable

        CUSTOM_INSPECT_EXCLUSIONS = [:@client].freeze
        include CustomInspectMixin

        def initialize(*_args)
          raise "Cannot instantiate a #{self.class}"
        end

        def each(&block)
          all.each(&block)
        end

        # find(#)      returns the object
        # find([#])    returns an array of the object
        # find(#, #, ...) or find([#, #, ...])   returns an array of the objects
        def find(*args)
          request_array = args.size == 1 && args[0].kind_of?(Array)
          args = args.flatten
          case args.size
          when 0
            raise "Couldn't find resource without an 'id'"
          when 1
            res = limit(1).where(:id => args[0]).to_a
            raise "Couldn't find resource with 'id' #{args}" if res.blank?
            request_array ? res : res.first
          else
            raise "Multiple resource find is not supported" unless respond_to?(:query)
            query(args.collect { |id| { "id" => id } })
          end
        end

        def find_by(args)
          limit(1).where(args).first
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

              define_method("get") do |options = {}|
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

        def search(mode, options)
          options[:limit] = 1 if mode == :first
          result = get(parameters_from_query_relation(options))
          case mode
          when :first then result.first
          when :last  then result.last
          when :all   then result
          else raise "Invalid mode #{mode} specified for search"
          end
        end

        private

        def parameters_from_query_relation(options)
          api_params = {}
          [:offset, :limit].each { |opt| api_params[opt] = options[opt] if options[opt] }
          api_params[:attributes] = options[:select].join(",") if options[:select].present?
          if options[:where]
            api_params[:filter] ||= []
            api_params[:filter] += filters_from_query_relation("=", options[:where])
          end
          if options[:not]
            api_params[:filter] ||= []
            api_params[:filter] += filters_from_query_relation("!=", options[:not])
          end
          if options[:order]
            order_parameters_from_query_relation(options[:order]).each { |param, value| api_params[param] = value }
          end
          api_params
        end

        def filters_from_query_relation(condition, option)
          filters = []
          option.each do |attr, values|
            Array(values).each do |value|
              value = "'#{value}'" if value.kind_of?(String) && !value.match(/^(NULL|nil)$/i)
              filters << "#{attr}#{condition}#{value}"
            end
          end
          filters
        end

        def order_parameters_from_query_relation(option)
          query_relation_option =
            if option.kind_of?(Array)
              option.each_with_object({}) { |name, hash| hash[name] = "asc" }
            else
              option.dup
            end

          res_sort_by = []
          res_sort_order = []
          query_relation_option.each do |sort_attr, sort_order|
            res_sort_by << sort_attr
            sort_order =
              case sort_order
              when /^asc/i  then "asc"
              when /^desc/i then "desc"
              else raise "Invalid sort order #{sort_order} specified for attribute #{sort_attr}"
              end
            res_sort_order << sort_order
          end
          { :sort_by => res_sort_by.join(","), :sort_order => res_sort_order.join(",") }
        end
      end
    end
  end
end
