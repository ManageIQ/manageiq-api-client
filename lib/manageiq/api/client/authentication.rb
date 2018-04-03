module ManageIQ
  module API
    class Client
      class Authentication
        attr_reader :user
        attr_reader :password
        attr_reader :token
        attr_reader :miqtoken
        attr_reader :group

        DEFAULTS = {
          :user     => "admin",
          :password => "smartvm"
        }.freeze

        CUSTOM_INSPECT_EXCLUSIONS = [:@password].freeze
        include ManageIQ::API::Client::CustomInspectMixin

        def initialize(options = {})
          @user, @password = fetch_credentials(options)
          @token, @miqtoken, @group = options.values_at(:token, :miqtoken, :group)

          unless token || miqtoken
            raise "Must specify both a user and a password" if user.blank? || password.blank?
          end
        end

        def self.auth_options_specified?(options)
          options.slice(:user, :password, :token, :miqtoken, :group).present?
        end

        private

        def fetch_credentials(options)
          if options.slice(:user, :password, :token, :miqtoken).blank?
            [DEFAULTS[:user], DEFAULTS[:password]]
          else
            [options[:user], options[:password]]
          end
        end
      end
    end
  end
end
