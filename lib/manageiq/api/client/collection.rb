module ManageIQ
  module API
    class Client
      class Collection
        include ManageIQ::API::Client::ActionMixin
        include Enumerable
        include ManageIQ::API::Client::QueryableMixin

        ACTIONS_RETURNING_RESOURCES = %w(create query).freeze

        CUSTOM_INSPECT_EXCLUSIONS = [:@client].freeze
        include ManageIQ::API::Client::CustomInspectMixin

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

        def options
          @collection_options ||= CollectionOptions.new(client.options(name))
        end

        def each(&block)
          all.each(&block)
        end

        def self.defined?(name)
          const_defined?(name.camelize, false)
        end

        def self.subclass(name)
          name = name.camelize

          if const_defined?(name, false)
            const_get(name, false)
          else
            const_set(name, Class.new(self))
          end
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

        def exec_action(name, *args, &block)
          action = find_action(name)
          body = action_body(action.name, *args, &block)
          bulk_request = body.key?("resources")
          res = client.send(action.method, URI(action.href)) { body }
          if ACTIONS_RETURNING_RESOURCES.include?(action.name) && res.key?("results")
            klass = ManageIQ::API::Client::Resource.subclass(self.name)
            res = results_to_objects(res["results"], klass)
            res = res[0] if !bulk_request && res.size == 1
          else
            res = res["results"].collect { |result| action_result(result) }
          end
          res
        end

        def results_to_objects(results, klass)
          results.collect do |resource_hash|
            if ManageIQ::API::Client::ActionResult.an_action_result?(resource_hash)
              ManageIQ::API::Client::ActionResult.new(resource_hash)
            else
              klass.new(self, resource_hash)
            end
          end
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

        def query_actions(href = name)
          result_hash = client.get(href, :limit => 1)
          fetch_actions(result_hash)
        end
      end
    end
  end
end
