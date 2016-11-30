describe ManageIQ::API::Client::ServerInfo do
  describe ".new" do
    before do
      @entrypoint_response = api_file_fixture("responses/entrypoint.json")
      @server_info_hash = JSON.parse(@entrypoint_response)["server_info"]
    end

    it "creates a new server info object" do
      expect(described_class.new(@server_info_hash)).to be_a(described_class)
    end

    it "creates a new server info object with all elements accessible as attributes" do
      server_info = described_class.new(@server_info_hash)
      @server_info_hash.each { |key, value| expect(server_info.public_send(key)).to eq(value) }
    end
  end
end
