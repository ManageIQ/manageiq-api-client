module ManageIQ
  module API
    class Client
      class ApiVersion
        attr_reader :name
        attr_reader :href

        def initialize(version_spec)
          @name, @href = version_spec.values_at("name", "href")
        end
      end
    end
  end
end
