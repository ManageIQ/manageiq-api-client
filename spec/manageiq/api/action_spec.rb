describe ManageIQ::API::Client::Action do
  describe ".new" do
    let(:href) { "http://localhost:3000/api/vms/10" }
    let(:name) { "start" }
    let(:method) { "post" }

    it "creates a new action" do
      action = described_class.new("href" => href, "method" => method, "name" => name)
      expect(action.name).to eq(name)
      expect(action.method).to eq(method)
      expect(action.href).to eq(href)
    end
  end
end
