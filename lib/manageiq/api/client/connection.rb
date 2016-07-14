module ManageIQ
  module API
    module Client
      class Connection
        attr_accessor :url
        attr_accessor :authentication
        attr_accessor :response
        attr_accessor :error

        API_PREFIX = "/api".freeze
        CONTENT_TYPE = "application/json".freeze

        def initialize(url, authentication)
          @url = url
          @authentication = authentication
          @error = ManageIQ::API::Client::Error.new
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
        end

        def json_response
          JSON.parse(response.body.strip)
        rescue
          {}
        end

        private

        def handle
          @handle = Faraday.new(:url => url, :ssl => {:verify => false}) do |faraday|
            faraday.request(:url_encoded) # form-encode POST params
            faraday.use FaradayMiddleware::FollowRedirects, :limit => 3, :standards_compliant => true
            faraday.adapter(Faraday.default_adapter) # make requests with Net::HTTP
            faraday.basic_auth(authentication.user, authentication.password) if authentication.token.blank?
          end
        end

        def send_request(method, path, params, &block)
          begin
            error.clear
            @response = handle.send(method) do |request|
              request.url URI.join(url, "#{API_PREFIX}/#{path}").to_s
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
            error.update(response.status, json_response)
            raise error.message
          end
        end
      end
    end
  end
end
