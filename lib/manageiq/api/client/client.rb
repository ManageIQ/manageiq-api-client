module ManageIQ
  module API
    class Client
      attr_reader :client_options
      attr_reader :logger
      attr_reader :url
      attr_reader :authentication
      attr_reader :connection

      attr_reader :api
      attr_reader :settings
      attr_reader :identity
      attr_reader :authorization
      attr_reader :collections

      DEFAULT_URL = URI.parse("http://localhost:3000")

      def self.logger
        @logger ||= NullLogger.new
      end

      def self.logger=(logger)
        @logger = logger
      end

      def initialize(client_options = {})
        @client_options = client_options.dup
        @logger = client_options[:logger] || self.class.logger
        @url = extract_url(client_options)
        @authentication = ManageIQ::API::Client::Authentication.new(client_options)
        reconnect
      end

      def load_definitions
        entrypoint     = connection.get("", :attributes => "authorization")
        @api           = ManageIQ::API::Client::API.new(entrypoint)
        @settings      = Hash(entrypoint["settings"]).dup
        @identity      = ManageIQ::API::Client::Identity.new(Hash(entrypoint["identity"]))
        @authorization = Hash(entrypoint["authorization"]).dup
        @collections   = load_collections(entrypoint["collections"])
      end

      def update_authentication(auth_options = {})
        return @authentication unless ManageIQ::API::Client::Authentication.auth_options_specified?(auth_options)
        saved_auth = @authentication
        @authentication = ManageIQ::API::Client::Authentication.new(auth_options)
        begin
          reconnect
        rescue
          @authentication = saved_auth
          raise
        end
        @authentication
      end

      def reconnect
        @connection = ManageIQ::API::Client::Connection.new(self, client_options.slice(:ssl))
        load_definitions
      end

      delegate :get, :post, :put, :patch, :delete, :options, :error, :to => :connection

      private

      def load_collections(collection_list)
        collection_list.collect do |collection_def|
          klass = ManageIQ::API::Client::Collection.subclass(collection_def["name"])
          collection = klass.new(self, collection_def)
          create_method(collection.name.to_sym) { collection }
          collection
        end
      end

      def extract_url(options)
        url = options[:url] || DEFAULT_URL
        url = URI.parse(url) unless url.kind_of?(URI)
        url
      rescue
        raise "Malformed ManageIQ Appliance URL #{url} specified"
      end

      def create_method(name, &block)
        self.class.send(:define_method, name, &block)
      end
    end
  end
end
