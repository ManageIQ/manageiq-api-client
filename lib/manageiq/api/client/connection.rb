module ManageIQ
  module API
    class Client
      class Connection
        attr_reader :url
        attr_reader :authentication
        attr_reader :client
        attr_reader :connection_options
        attr_reader :response
        attr_reader :error

        delegate :url, :authentication, :to => :client

        API_PREFIX = "/api".freeze
        CONTENT_TYPE = "application/json".freeze

        def initialize(client, connection_options = {})
          @client = client
          @connection_options = connection_options
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

        def options(path = "", params = {})
          send_request(:options, path, params)
          json_response
        end

        def json_response
          resp = response.body.strip
          resp.blank? ? {} : JSON.parse(resp)
        rescue
          raise JSON::ParserError, "Response received from #{url} is not of type #{CONTENT_TYPE}"
        end

        def api_path(path)
          if path.to_s.starts_with?(url.to_s)
            path.to_s
          elsif path.to_s.blank?
            URI.join(url, API_PREFIX).to_s
          else
            URI.join(url, path.to_s.starts_with?(API_PREFIX) ? path.to_s : "#{API_PREFIX}/#{path}").to_s
          end
        end

        def handle
          ssl_options = @connection_options[:ssl]
          Faraday.new(:url => url, :ssl => ssl_options) do |faraday|
            faraday.request(:url_encoded) # form-encode POST params
            faraday.options.open_timeout = @connection_options[:open_timeout] if @connection_options[:open_timeout]
            faraday.options.timeout      = @connection_options[:timeout]      if @connection_options[:timeout]
            faraday.response(:logger, client.logger)
            faraday.use FaradayMiddleware::FollowRedirects, :limit => 3, :standards_compliant => true
            faraday.adapter(Faraday.default_adapter) # make requests with Net::HTTP
            if authentication.token.blank? && authentication.miqtoken.blank?
              faraday.basic_auth(authentication.user, authentication.password)
            end
          end
        end

        private

        def send_request(method, path, params, &block)
          begin
            @error = nil
            @response = handle.run_request(method.to_sym, api_path(path), nil, nil) do |request|
              request.headers[:content_type]  = CONTENT_TYPE
              request.headers[:accept]        = CONTENT_TYPE
              request.headers['X-MIQ-Group']  = authentication.group unless authentication.group.blank?
              request.headers['X-Auth-Token'] = authentication.token unless authentication.token.blank?
              request.headers['X-MIQ-Token']  = authentication.miqtoken unless authentication.miqtoken.blank?
              request.params.merge!(params)
              request.body = yield(block).to_json if block
            end
          rescue => err
            raise "Failed to send request to #{url} - #{err}"
          end
          check_response
        end

        def check_response
          if response.status == 404
            message = json_response.fetch_path("error", "message") || json_response["error"]
            raise ManageIQ::API::Client::ResourceNotFound, message
          elsif response.status >= 400
            @error = ManageIQ::API::Client::Error.new(response.status, json_response)
            raise @error.message
          end
        end
      end
    end
  end
end
