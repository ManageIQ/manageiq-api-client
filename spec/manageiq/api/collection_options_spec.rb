describe ManageIQ::API::Client::CollectionOptions do
  describe ".new" do
    before do
      @groups_options_hash = JSON.parse(api_file_fixture("responses/options_groups.json"))
    end

    it "creates a new collection options object" do
      expect(described_class.new(@groups_options_hash)).to be_a(described_class)
    end

    it "allows access of collection options elements by attribute" do
      groups_options = described_class.new(@groups_options_hash)
      @groups_options_hash.each { |key, value| expect(groups_options.public_send(key)).to eq(value) }
    end
  end
end
