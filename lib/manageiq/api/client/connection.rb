module ManageIQ
  module API
    class Client
      class Connection
        attr_accessor :url
        attr_accessor :authentication
        attr_accessor :options
        attr_accessor :response
        attr_accessor :error

        API_PREFIX = "/api".freeze
        CONTENT_TYPE = "application/json".freeze

        def initialize(url, authentication, connection_options = {})
          @url = url
          @authentication = authentication
          @options = connection_options
          @error = nil
        end

        def get(path = "", params = {})
          send_request(:get, path, params)
          json_response
        end

        def put(path, params = {}, &block)
          send_request(:put, path, params, &block)
          json_response
        end

        def post(path, params = {}, &block)
          send_request(:post, path, params, &block)
          json_response
        end

        def patch(path, params = {}, &block)
          send_request(:patch, path, params, &block)
          json_response
        end

        def delete(path, params = {})
          send_request(:delete, path, params)
          json_response
        end

        def json_response
          resp = response.body.strip
          resp.blank? ? {} : JSON.parse(resp)
        rescue
          raise JSON::ParserError, "Response received from #{url} is not of type #{CONTENT_TYPE}"
        end

        def fetch_token
          @authentication.token = nil
          res = get "auth"
          @authentication.token = res["auth_token"]
        end

        private

        def handle
          ssl_options = @options[:ssl]
          Faraday.new(:url => url, :ssl => ssl_options) do |faraday|
            faraday.request(:url_encoded) # form-encode POST params
            faraday.use FaradayMiddleware::FollowRedirects, :limit => 3, :standards_compliant => true
            faraday.adapter(Faraday.default_adapter) # make requests with Net::HTTP
            faraday.basic_auth(authentication.user, authentication.password) if authentication.token.blank?
          end
        end

        def send_request(method, path, params, &block)
          begin
            @error = nil
            @response = handle.send(method) do |request|
              path = URI.join(url, "#{API_PREFIX}/#{path}").to_s unless path.is_a?(URI)
              request.url path
              request.headers[:content_type]  = CONTENT_TYPE
              request.headers[:accept]        = CONTENT_TYPE
              request.headers['X-MIQ-Group']  = authentication.group unless authentication.group.blank?
              request.headers['X-Auth-Token'] = authentication.token unless authentication.token.blank?
              request.params.merge!(params)
              request.body = yield(block).to_json if block
            end
          rescue => err
            raise "Failed to send request to #{url} - #{err}"
          end
          check_response
        end

        def check_response
          if response.status >= 400
            @error = ManageIQ::API::Client::Error.new(response.status, json_response)
            raise @error.message
          end
        end
      end
    end
  end
end
