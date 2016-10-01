module ManageIQ
  module API
    class Client
      class ProductInfo
        attr_reader :name
        attr_reader :name_full
        attr_reader :copyright
        attr_reader :support_website
        attr_reader :support_website_text

        def initialize(product_info)
          @name, @name_full, @copyright, @support_website, @support_website_text =
            product_info.values_at("name", "name_full", "copyright", "support_website", "support_website_text")
        end
      end
    end
  end
end
