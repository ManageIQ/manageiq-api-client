module ManageIQ
  module API
    module Client
      class ApiVersion
        attr_accessor :name
        attr_accessor :href

        def initialize(version_spec)
          @name = version_spec["name"]
          @href = version_spec["href"]
        end
      end
    end
  end
end
