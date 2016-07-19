module ManageIQ
  module API
    class Client
      class Action
        attr_accessor :name
        attr_accessor :method
        attr_accessor :href

        def initialize(action_hash)
          @name, @method, @href = action_hash.values_at("name", "method", "href")
        end
      end
    end
  end
end
