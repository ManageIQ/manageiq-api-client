module ManageIQ
  module API
    module Client
      class Authentication
        attr_accessor :user, :password, :token, :group

        DEFAULTS = {
          :user     => "admin",
          :password => "smartvm"
        }.freeze

        def initialize(options = {})
          @user, @password = fetch_credentials(options)
          @token = options[:token]
          @group = options[:group]

          unless token
            raise "Must specify both a user and a password" if user.blank? || password.blank?
          end
        end

        def inspect
          super.gsub(/@password=\".+?\", /, "")
        end

        private

        def fetch_credentials(options)
          if options.slice(:user, :password, :token).blank?
            [DEFAULTS[:user], DEFAULTS[:password]]
          else
            [options[:user], options[:password]]
          end
        end
      end
    end
  end
end
