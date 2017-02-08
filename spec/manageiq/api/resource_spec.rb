describe ManageIQ::API::Client::Resource do
  let(:api_url) { "http://localhost:3000/api" }
  let(:vms_url) { "#{api_url}/vms" }
  let(:vms_expand_url) { "#{vms_url}?expand=resources" }
  let(:entrypoint_request_url) { "#{api_url}?attributes=authorization" }

  let(:entrypoint_response)     { api_file_fixture("responses/entrypoint.json") }
  let(:get_test1_vms_response)  { api_file_fixture("responses/get_test1_vms.json") }
  let(:actions_vms_response)    { api_file_fixture("responses/actions_vms.json") }

  describe "resource" do
    before do
      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => entrypoint_response, :headers => {})

      stub_request(:get, "#{vms_expand_url}&filter[]=name='aab-test1'&limit=1")
        .to_return(:status => 200, :body => get_test1_vms_response, :headers => {})

      miq = ManageIQ::API::Client.new
      @vm = miq.vms.where(:name => "aab-test1").first
      @vm_hash = JSON.parse(get_test1_vms_response)["resources"].first
    end

    it "is of valid type" do
      expect(@vm).to be_a(ManageIQ::API::Client::Resource::Vm)
    end

    it "exposes attributes hash" do
      expect(@vm.attributes).to match(a_hash_including(@vm_hash.except("actions")))
    end

    it "exposes action objects" do
      expect(@vm.actions.first).to be_a(ManageIQ::API::Client::Action)
    end

    it "exposes related collection" do
      expect(@vm.collection).to be_a(ManageIQ::API::Client::Collection::Vms)
    end

    it "exposes attributes" do
      expect(@vm.id).to eq(@vm_hash["id"])
      expect(@vm.name).to eq(@vm_hash["name"])
      expect(@vm.vendor).to eq(@vm_hash["vendor"])
    end

    it "exposes attributes via []" do
      expect(@vm["id"]).to eq(@vm_hash["id"])
      expect(@vm["name"]).to eq(@vm_hash["name"])
      expect(@vm["vendor"]).to eq(@vm_hash["vendor"])
    end

    it "responds to actions" do
      @vm_hash["actions"].each do |aspec|
        if aspec["method"] == "post"
          expect(@vm.respond_to?(aspec["name"].to_sym)).to be_truthy
        end
      end
    end

    it "supports invoking actions" do
      action = @vm_hash["actions"].detect { |aspec| aspec["method"] == "post" }

      stub_request(:post, @vm_hash["href"])
        .with(:body => {"action" => action["name"]}, :headers => {'Content-Type' => 'application/json'})
        .to_return(:status => 200, :body => actions_vms_response, :headers => {})

      @vm.public_send(action["name"])
    end

    it "supports invoking actions with parameters" do
      action = @vm_hash["actions"].detect { |aspec| aspec["method"] == "post" }

      stub_request(:post, @vm_hash["href"])
        .with(:body    => {"action"   => action["name"],
                           "resource" => { "parameter" => "value" }},
              :headers => {'Content-Type' => 'application/json'})
        .to_return(:status => 200, :body => actions_vms_response, :headers => {})

      @vm.public_send(action["name"], :parameter => "value")
    end
  end
end
