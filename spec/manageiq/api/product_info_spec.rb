describe ManageIQ::API::Client::ProductInfo do
  describe "#new" do
    let(:product_info_hash) do
      {
        "name"                 => "ManageIQ",
        "name_full"            => "ManageIQ",
        "copyright"            => "Copyright (c) 2016 ManageIQ. Sponsored by Red Hat Inc.",
        "support_website"      => "http://www.manageiq.org",
        "support_website_text" => "ManageIQ.org"
      }
    end

    it "creates a new product info object" do
      expect(described_class.new(product_info_hash)).to be_a(described_class)
    end

    it "creates a new product info with all elements accessible as attributes" do
      product_info = described_class.new(product_info_hash)
      product_info_hash.each { |key, value| expect(product_info.public_send(key)).to eq(value) }
    end
  end
end
