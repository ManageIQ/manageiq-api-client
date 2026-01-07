module ManageIQ
  module API
    class Client
      class ServerInfo
        attr_reader :version
        attr_reader :build
        attr_reader :appliance
        attr_reader :server_href
        attr_reader :zone_href
        attr_reader :region_href
        attr_reader :release
        attr_reader :time
        attr_reader :enterprise_href
        attr_reader :plugins

        def initialize(server_info)
          @version, @build, @appliance, @server_href, @zone_href, @region_href, @release, @time, @enterprise_href, @plugins =
            server_info.values_at("version", "build", "appliance", "server_href", "zone_href", "region_href", "release", "time", "enterprise_href", "plugins")
        end
      end
    end
  end
end
