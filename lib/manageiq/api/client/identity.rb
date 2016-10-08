module ManageIQ
  module API
    class Client
      class Identity
        attr_reader :userid
        attr_reader :name
        attr_reader :user_href
        attr_reader :group
        attr_reader :group_href
        attr_reader :role
        attr_reader :role_href
        attr_reader :tenant
        attr_reader :groups

        def initialize(identity_spec)
          @userid      = identity_spec["userid"]
          @name        = identity_spec["name"]
          @user_href   = identity_spec["user_href"]
          @group       = identity_spec["group"]
          @group_href  = identity_spec["group_href"]
          @role        = identity_spec["role"]
          @role_href   = identity_spec["role_href"]
          @tenant      = identity_spec["tenant"]
          @groups      = identity_spec["groups"]
        end
      end
    end
  end
end
