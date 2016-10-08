module ManageIQ
  module API
    class Client
      class Action
        attr_reader :name
        attr_reader :method
        attr_reader :href

        def initialize(action_hash)
          @name, @method, @href = action_hash.values_at("name", "method", "href")
        end
      end
    end
  end
end
