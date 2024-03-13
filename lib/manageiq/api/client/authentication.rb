module ManageIQ
  module API
    class Client
      class Authentication
        attr_reader :user
        attr_reader :password
        attr_reader :token
        attr_reader :miqtoken
        attr_reader :bearer_token
        attr_reader :group

        DEFAULTS = {
          :user     => "admin",
          :password => "smartvm"
        }.freeze

        CUSTOM_INSPECT_EXCLUSIONS = %i[@password @token @miqtoken @bearer_token].freeze
        include CustomInspectMixin

        def initialize(options = {})
          @user, @password = fetch_credentials(options)
          @token, @miqtoken, @bearer_token, @group = options.values_at(:token, :miqtoken, :bearer_token, :group)

          unless token || miqtoken || bearer_token
            raise "Must specify both a user and a password" if user.nil? || user.empty? || password.nil? || password.empty?
          end
        end

        def self.auth_options_specified?(options)
          !options.slice(:user, :password, :token, :miqtoken, :bearer_token, :group).empty?
        end

        private

        def fetch_credentials(options)
          if options.slice(:user, :password, :token, :miqtoken, :bearer_token).empty?
            [DEFAULTS[:user], DEFAULTS[:password]]
          else
            [options[:user], options[:password]]
          end
        end
      end
    end
  end
end
