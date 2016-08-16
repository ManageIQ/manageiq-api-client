module ManageIQ
  module API
    class Client
      class Collection
        include ActionMixin
        include ActsAsArQueryMixin

        def initialize(*_args)
          raise "Cannot instantiate a #{self.class}"
        end

        def self.subclass(name)
          klass_name = name.camelize

          if const_defined?(klass_name)
            const_get(klass_name)
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

              define_method("search") do |options = {}|
                options[:expand] = (String(options[:expand]).split(",") | %w(resources)).join(",")
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

        def ar_search(options)
          search(query_parameters_from_ar_query_options(options))
        end

        private

        def query_parameters_from_ar_query_options(options)
          api_params = {}
          [:offset, :limit].each { |opt| api_params[opt] = options[opt] if options[opt] }
          api_params[:attributes] = options[:select].join(",") if options[:select].present?
          if options[:where]
            api_params[:filter] ||= []
            conditional_parameter_from_ar_query_options(api_params[:filter], "=", options[:where])
          end
          if options[:not]
            api_params[:filter] ||= []
            conditional_parameter_from_ar_query_options(api_params[:filter], "!=", options[:not])
          end
          if options[:order]
            order_parameters_from_ar_query_options(api_params, options[:order])
          end
          api_params
        end

        def conditional_parameter_from_ar_query_options(filter_param, condition, ar_option)
          ar_option.each do |attr, values|
            Array(values).each do |value|
              value = "'#{value}'" if value.kind_of?(String) && !value.match(/^(NULL|nil)$/i)
              filter_param << "#{attr}#{condition}#{value}"
            end
          end
        end

        def order_parameters_from_ar_query_options(api_params, ar_option)
          api_params[:sort_by] = []
          api_params[:sort_order] = []
          ar_option.each do |sort_attr, sort_order|
            api_params[:sort_by] << sort_attr
            case sort_order
            when /^asc/i
              sort_order = "asc"
            when /^desc/i
              sort_order = "desc"
            else
              raise "Invalid sort order #{sort_order} specified for attribute #{sort_attr}"
            end
            api_params[:sort_order] << sort_order
          end
          api_params[:sort_by] = api_params[:sort_by].join(",")
          api_params[:sort_order] = api_params[:sort_order].join(",")
        end
      end
    end
  end
end
