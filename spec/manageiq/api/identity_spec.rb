describe ManageIQ::API::Client::Identity do
  describe ".new" do
    before do
      @entrypoint_response = api_file_fixture("responses/entrypoint.json")
      @identity_hash = JSON.parse(@entrypoint_response)["identity"]
    end

    it "creates a new identity object" do
      expect(described_class.new(@identity_hash)).to be_a(described_class)
    end

    it "creates a new identity object with all elements accessible as attributes" do
      identity = described_class.new(@identity_hash)
      @identity_hash.each { |key, value| expect(identity.public_send(key)).to eq(value) }
    end
  end
end
