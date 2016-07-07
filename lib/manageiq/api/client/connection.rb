module ManageIQ
  module API
    module Client
      class Connection
        attr_accessor :authentication
        attr_accessor :handle
        attr_accessor :options
        attr_accessor :server

        def initialize(options = {})
          @server         = ManageIQ::API::Client::Server.new(options)
          @authentication = ManageIQ::API::Client::Authentication.new(options)
          @options        = options.dup
        end

        def handle
          @handle ||= Faraday.new(:url => server.url, :ssl => {:verify => false}) do |faraday|
            faraday.request(:url_encoded) # form-encode POST params
            faraday.response(:logger) if options[:verbose]
            faraday.use FaradayMiddleware::FollowRedirects, :limit => 3, :standards_compliant => true
            faraday.adapter(Faraday.default_adapter) # make requests with Net::HTTP
            faraday.basic_auth(authentication.user, authentication.password) if authentication.token.blank?
          end
        end
      end
    end
  end
end
