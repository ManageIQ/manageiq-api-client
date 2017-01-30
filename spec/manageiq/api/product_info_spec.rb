describe ManageIQ::API::Client::ProductInfo do
  describe ".new" do
    before do
      @entrypoint_response = api_file_fixture("responses/entrypoint.json")
      @product_info_hash = JSON.parse(@entrypoint_response)["product_info"]
    end

    it "creates a new product info object" do
      expect(described_class.new(@product_info_hash)).to be_a(described_class)
    end

    it "creates a new product info with all elements accessible as attributes" do
      product_info = described_class.new(@product_info_hash)
      @product_info_hash.each { |key, value| expect(product_info.public_send(key)).to eq(value) }
    end
  end
end
