module ManageIQ
  module API
    module Client
      class Server
        attr_accessor :options
        attr_accessor :url
        attr_accessor :authentication
        attr_accessor :connection

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
        end
      end
    end
  end
end
