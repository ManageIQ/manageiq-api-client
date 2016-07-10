module ManageIQ
  module API
    module Client
      class Identity
        attr_accessor :userid
        attr_accessor :name
        attr_accessor :user_href
        attr_accessor :group
        attr_accessor :group_href
        attr_accessor :role
        attr_accessor :role_href
        attr_accessor :tenant
        attr_accessor :groups

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
