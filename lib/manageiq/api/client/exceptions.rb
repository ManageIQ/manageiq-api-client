module ManageIQ
  module API
    class Client
      class Exception < ::RuntimeError; end
      class ResourceNotFound < ManageIQ::API::Client::Exception; end
    end
  end
end
