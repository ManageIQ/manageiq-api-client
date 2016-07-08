module ManageIQ
  module API
    module Client
      class Connection
        attr_accessor :url
        attr_accessor :authentication

        def initialize(url, authentication)
          @url = url
          @authentication = authentication
        end

        def handle
          @handle ||= Faraday.new(:url => url, :ssl => {:verify => false}) do |faraday|
            faraday.request(:url_encoded) # form-encode POST params
            faraday.use FaradayMiddleware::FollowRedirects, :limit => 3, :standards_compliant => true
            faraday.adapter(Faraday.default_adapter) # make requests with Net::HTTP
            faraday.basic_auth(authentication.user, authentication.password) if authentication.token.blank?
          end
        end
      end
    end
  end
end
