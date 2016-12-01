describe ManageIQ::API::Client::API do
  let(:api_url) { "http://localhost:3000/api" }

  describe ".new" do
    let(:api_version_220) do
      {
        "name" => "2.2.0",
        "href" => "#{api_url}/v2.2.0"
      }
    end
    let(:api_version_230) do
      {
        "name" => "2.3.0",
        "href" => "#{api_url}/v2.3.0"
      }
    end
    let(:api_entrypoint_hash) do
      {
        "name"        => "API",
        "description" => "REST API",
        "version"     => "2.3.0",
        "versions"    => [api_version_220, api_version_230]
      }
    end

    it "creates a new Api object" do
      expect(described_class.new(api_entrypoint_hash)).to be_a(described_class)
    end

    it "creates a new Api object with all elements accessible as attributes" do
      api = described_class.new(api_entrypoint_hash)
      %w(name description version).each { |key| expect(api.public_send(key)).to eq(api_entrypoint_hash[key]) }
    end

    it "creates a new Api object with versions returned as ApiVersion objects" do
      api = described_class.new(api_entrypoint_hash)
      versions = api.versions
      versions.each { |version| expect(version).to be_a(ManageIQ::API::Client::ApiVersion) }
      expect(versions.collect(&:name)).to match_array([api_version_220["name"], api_version_230["name"]])
    end
  end
end
