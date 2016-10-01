require 'logger'

module ManageIQ
  module API
    class Client
      class NullLogger < Logger
        def initialize(*_args)
        end

        def add(*_args, &_block)
        end
      end
    end
  end
end
