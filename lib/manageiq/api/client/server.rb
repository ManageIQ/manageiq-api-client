module ManageIQ
  module API
    module Client
      class Server
        attr_accessor :url

        def initialize(options = {})
          @url = options[:url]
          raise "Must specify a ManageIQ Appliance URL" if url.blank?
          begin
            URI.parse(url)
          rescue
            raise "Malformed ManageIQ Appliance URL #{url}"
          end
          url
        end
      end
    end
  end
end
