module ManageIQ
  module API
    class Client
      attr_accessor :options
      attr_accessor :url
      attr_accessor :authentication
      attr_accessor :connection

      attr_accessor :api
      attr_accessor :settings
      attr_accessor :identity
      attr_accessor :authorization
      attr_accessor :collections

      DEFAULT_URL = URI.parse("http://localhost:3000")

      def initialize(options = {})
        @options = options.dup
        @url = extract_url(options)
        @authentication = ManageIQ::API::Client::Authentication.new(options)
        reconnect
      end

      def load_definitions
        entrypoint     = connection.get("", :attributes => "authorization")
        @api           = ManageIQ::API::Client::API.new(entrypoint)
        @settings      = entrypoint["settings"].dup
        @identity      = ManageIQ::API::Client::Identity.new(entrypoint["identity"])
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
        @connection = ManageIQ::API::Client::Connection.new(self, options.slice(:ssl))
        load_definitions
      end

      delegate :get, :post, :put, :patch, :delete, :error, :to => :connection

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
