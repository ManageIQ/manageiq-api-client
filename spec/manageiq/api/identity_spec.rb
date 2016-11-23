describe ManageIQ::API::Client::Identity do
  describe "#new" do
    let(:identity_hash) do
      {
        "userid"     => "admin",
        "name"       => "Administrator",
        "user_href"  => "http://localhost:3000/api/users/1",
        "group"      => "EvmGroup-super_administrator",
        "group_href" => "http://localhost:3000/api/groups/2",
        "role"       => "EvmRole-super_administrator",
        "role_href"  => "http://localhost:3000/api/roles/1",
        "tenant"     => "My Company",
        "groups"     => ["EvmGroup-super_administrator"]
      }
    end

    it "creates a new identity object" do
      expect(described_class.new(identity_hash)).to be_a(described_class)
    end

    it "creates a new identity object with all elements accessible as attributes" do
      identity = described_class.new(identity_hash)
      identity_hash.each { |key, value| expect(identity.public_send(key)).to eq(value) }
    end
  end
end
