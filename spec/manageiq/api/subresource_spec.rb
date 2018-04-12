describe ManageIQ::API::Client::Resource do
  let(:api_url)                 { "http://localhost:3000/api" }
  let(:vms_url)                 { "#{api_url}/vms" }
  let(:tags_url)                { "#{api_url}/tags" }
  let(:vms_expand_url)          { "#{vms_url}?expand=resources" }
  let(:entrypoint_request_url)  { "#{api_url}?attributes=authorization" }

  let(:entrypoint_response)     { api_file_fixture("responses/entrypoint.json") }
  let(:options_vms_response)    { api_file_fixture("responses/options_vms.json") }
  let(:options_tags_response)   { api_file_fixture("responses/options_tags.json") }
  let(:get_test1_vms_response)  { api_file_fixture("responses/get_test1_vms.json") }
  let(:get_test1_tags_response) { api_file_fixture("responses/get_test1_vm_tags.json") }
  let(:actions_tags_response)   { api_file_fixture("responses/actions_vm_tags.json") }

  before do
    stub_request(:get, entrypoint_request_url)
      .to_return(:status => 200, :body => entrypoint_response, :headers => {})

    stub_request(:get, "#{vms_expand_url}&filter[]=name='aab-test1'&limit=1")
      .to_return(:status => 200, :body => get_test1_vms_response, :headers => {})

    stub_request(:options, vms_url)
      .to_return(:status => 200, :body => options_vms_response, :headers => {})

    stub_request(:options, tags_url)
      .to_return(:status => 200, :body => options_tags_response, :headers => {})

    miq = ManageIQ::API::Client.new
    @vm = miq.vms.where(:name => "aab-test1").first
    @vm_options = JSON.parse(options_vms_response)
    @vm_hash = JSON.parse(get_test1_vms_response)["resources"].first

    stub_request(:get, "#{vms_url}/#{@vm.id}/tags?hide=resources")
      .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

    stub_request(:get, "#{vms_url}/#{@vm.id}/tags?expand=resources&limit=1")
      .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

    @vm_tag = @vm.tags.first
    @vm_tag1 = JSON.parse(get_test1_tags_response)["resources"].first
  end

  describe "subresource" do
    it "is of valid type" do
      expect(@vm_tag).to be_a(ManageIQ::API::Client::Resource::Tag)
    end

    it "exposes attributes hash" do
      expect(@vm_tag.attributes).to match(a_hash_including(@vm_tag1.except("actions")))
    end

    it "exposes action objects" do
      expect(@vm_tag.actions.first).to be_a(ManageIQ::API::Client::Action)
    end

    it "exposes related subcollection" do
      expect(@vm_tag.collection).to be_a(ManageIQ::API::Client::Subcollection::Tags)
    end

    it "exposes attributes" do
      expect(@vm_tag.id).to eq(@vm_tag1["id"])
      expect(@vm_tag.name).to eq(@vm_tag1["name"])
      expect(@vm_tag.href).to eq(@vm_tag1["href"])
    end

    it "exposes attributes via []" do
      expect(@vm_tag["id"]).to eq(@vm_tag1["id"])
      expect(@vm_tag["name"]).to eq(@vm_tag1["name"])
      expect(@vm_tag["href"]).to eq(@vm_tag1["href"])
    end

    it "responds to actions" do
      @vm_tag1["actions"].each do |aspec|
        if aspec["method"] == "post"
          expect(@vm_tag.respond_to?(aspec["name"].to_sym)).to be_truthy
        end
      end
    end

    it "supports invoking actions" do
      action = @vm_tag1["actions"].detect { |aspec| aspec["method"] == "post" }

      stub_request(:post, @vm_tag["href"])
        .with(:body => {"action" => action["name"]}, :headers => {'Content-Type' => 'application/json'})
        .to_return(:status => 200, :body => actions_tags_response, :headers => {})

      @vm_tag.public_send(action["name"])
    end

    it "supports invoking actions with parameters" do
      action = @vm_tag1["actions"].detect { |aspec| aspec["method"] == "post" }

      stub_request(:post, @vm_tag["href"])
        .with(:body    => {"action"   => action["name"],
                           "resource" => { "parameter" => "value" }},
              :headers => {'Content-Type' => 'application/json'})
        .to_return(:status => 200, :body => actions_tags_response, :headers => {})

      @vm_tag.public_send(action["name"], :parameter => "value")
    end
  end
end
