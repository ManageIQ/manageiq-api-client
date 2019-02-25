module ManageIQ
  module API
    class Client
      class Collection
        include ActionMixin
        include Enumerable
        include QueryRelation::Queryable

        CUSTOM_INSPECT_EXCLUSIONS = [:@client].freeze
        include CustomInspectMixin

        ACTIONS_RETURNING_RESOURCES = %w(create query).freeze

        attr_reader :client

        attr_reader :name
        attr_reader :href
        attr_reader :description
        attr_reader :actions

        def initialize(client, collection_spec)
          raise "Cannot instantiate a Collection directly" if instance_of?(Collection)
          @client = client
          @name, @href, @description = collection_spec.values_at("name", "href", "description")
          clear_actions
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
            raise ManageIQ::API::Client::ResourceNotFound, "Couldn't find resource with 'id' #{args}" if res.blank?
            request_array ? res : res.first
          else
            raise "Multiple resource find is not supported" unless respond_to?(:query)
            query(args.collect { |id| { "id" => id } })
          end
        end

        def find_by(args)
          limit(1).where(args).first
        end

        def pluck(*attrs)
          select(*attrs).to_a.pluck(*attrs)
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
          result_hash = client.get(name, options)
          fetch_actions(result_hash)
          klass = ManageIQ::API::Client::Resource.subclass(name)
          result_hash["resources"].collect do |resource_hash|
            klass.new(self, resource_hash)
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

        def options
          @collection_options ||= CollectionOptions.new(client.options(name))
        end

        private

        def method_missing(sym, *args, &block)
          query_actions unless actions_present?
          if action_defined?(sym)
            exec_action(sym, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(sym, *_)
          query_actions unless actions_present?
          action_defined?(sym) || super
        end

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

        def exec_action(name, *args, &block)
          action = find_action(name)
          body = action_body(action.name, *args, &block)
          bulk_request = body.key?("resources")
          res = client.send(action.method, URI(action.href)) { body }
          if ACTIONS_RETURNING_RESOURCES.include?(action.name) && res.key?("results")
            klass = ManageIQ::API::Client::Resource.subclass(self.name)
            res = res["results"].collect { |resource_hash| klass.new(self, resource_hash) }
            res = res[0] if !bulk_request && res.size == 1
          else
            res = res["results"].collect { |result| action_result(result) }
          end
          res
        end

        def action_body(action_name, *args, &block)
          args = args.flatten
          args = args.first if args.size == 1 && args.first.kind_of?(Hash)
          args = {} if args.blank?
          block_data = block ? block.call : {}
          body = { "action" => action_name }
          if block_data.present?
            if block_data.kind_of?(Array)
              body["resources"] = block_data.collect { |resource| resource.merge(args) }
            elsif args.present? && args.kind_of?(Array)
              body["resources"] = args.collect { |resource| resource.merge(block_data) }
            else
              body["resource"] = args.dup.merge!(block_data)
            end
          elsif args.present?
            body[args.kind_of?(Array) ? "resources" : "resource"] = args
          end
          body
        end

        def query_actions
          result_hash = client.get(name, :limit => 1)
          fetch_actions(result_hash)
        end
      end
    end
  end
end
