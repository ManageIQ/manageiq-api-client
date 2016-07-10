module ManageIQ
  module API
    module Client
      class Server
        attr_accessor :options
        attr_accessor :url
        attr_accessor :authentication
        attr_accessor :connection

        attr_accessor :api
        attr_accessor :settings
        attr_accessor :identity
        attr_accessor :authorization
        attr_accessor :collections

        def initialize(options = {})
          @options = options.dup
          @url = options[:url]
          raise "Must specify a ManageIQ Appliance URL" if url.blank?
          begin
            URI.parse(url)
          rescue
            raise "Malformed ManageIQ Appliance URL #{url}"
          end

          @authentication = ManageIQ::API::Client::Authentication.new(options)
          @connection = ManageIQ::API::Client::Connection.new(url, authentication)
          load_definitions
        end

        def load_definitions
          entrypoint     = connection.get("", :attributes => "authorization")
          @api           = ManageIQ::API::Client::ServerApi.new(entrypoint)
          @settings      = entrypoint["settings"].dup
          @identity      = ManageIQ::API::Client::Identity.new(entrypoint["identity"])
          @authorization = entrypoint["authorization"].dup
          @collections   = entrypoint["collections"].collect do |collection_def|
            ManageIQ::API::Client::Collection.new(collection_def)
          end
        end
      end
    end
  end
end
