module ManageIQ
  module API
    class Client
      class ServerInfo
        attr_reader :version
        attr_reader :build
        attr_reader :appliance

        def initialize(server_info)
          @version, @build, @appliance =
            server_info.values_at("version", "build", "appliance")
        end
      end
    end
  end
end
