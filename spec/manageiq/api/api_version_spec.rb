describe ManageIQ::API::Client::ApiVersion do
  describe ".new" do
    let(:api_version_hash) do
      {
        "name" => "2.3.0",
        "href" => "http://localhost:3000/api/v2.3.0"
      }
    end

    it "creates a new ApiVersion object" do
      expect(described_class.new(api_version_hash)).to be_a(described_class)
    end

    it "creates a new ApiVersion object with all elements accessible as attributes" do
      api_version = described_class.new(api_version_hash)
      api_version_hash.each { |key, value| expect(api_version.public_send(key)).to eq(value) }
    end
  end
end
