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

        def initialize(server_info)
          @version, @build, @appliance, @server_href, @zone_href, @region_href =
            server_info.values_at("version", "build", "appliance", "server_href", "zone_href", "region_href")
        end
      end
    end
  end
end
