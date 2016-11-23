describe ManageIQ::API::Client::ServerInfo do
  describe "#new" do
    let(:server_info_hash) do
      {
        "version"   => "master",
        "build"     => "20161123094855_67f8027",
        "appliance" => "EVM"
      }
    end

    it "creates a new server info object" do
      expect(described_class.new(server_info_hash)).to be_a(described_class)
    end

    it "creates a new server info object with all elements accessible as attributes" do
      server_info = described_class.new(server_info_hash)
      server_info_hash.each { |key, value| expect(server_info.public_send(key)).to eq(value) }
    end
  end
end
