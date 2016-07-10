module ManageIQ
  module API
    module Client
      class Action
        attr_accessor :name
        attr_accessor :method
        attr_accessor :href

        def initialize(action_hash)
          @name   = action_hash["name"]
          @method = action_hash["method"]
          @href   = action_hash["href"]
        end
      end
    end
  end
end
