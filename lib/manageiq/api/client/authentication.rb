module ManageIQ
  module API
    module Client
      class Authentication
        attr_accessor :user, :password, :token, :group

        def initialize(options = {})
          @user, @password, @token, @group = options[:user], options[:password], options[:token], options[:group]

          unless token
            raise "Must specify both a user and a password" if user.blank? && password.blank?
          end
        end
      end
    end
  end
end
