describe ManageIQ::API::Client::Subcollection do
  let(:api_url)                    { "http://localhost:3000/api" }
  let(:entrypoint_request_url)     { "#{api_url}?attributes=authorization" }
  let(:vms_url)                    { "#{api_url}/vms" }
  let(:vms_expand_url)             { "#{vms_url}?expand=resources" }

  let(:entrypoint_response)        { api_file_fixture("responses/entrypoint.json") }
  let(:options_vms_response)       { api_file_fixture("responses/options_vms.json") }
  let(:get_test1_vms_response)     { api_file_fixture("responses/get_test1_vms.json") }
  let(:get_test1_tags_response)    { api_file_fixture("responses/get_test1_vm_tags.json") }
  let(:get_test1_no_tags_response) { api_file_fixture("responses/get_test1_vm_no_tags.json") }
  let(:actions_vm_tags_response)   { api_file_fixture("responses/actions_vm_tags.json") }

  before do
    stub_request(:get, entrypoint_request_url)
      .to_return(:status => 200, :body => entrypoint_response, :headers => {})

    stub_request(:get, "#{vms_expand_url}&filter[]=name='aab-test1'&limit=1")
      .to_return(:status => 200, :body => get_test1_vms_response, :headers => {})

    stub_request(:options, vms_url)
      .to_return(:status => 200, :body => options_vms_response, :headers => {})

    miq = ManageIQ::API::Client.new
    @vm = miq.vms.where(:name => "aab-test1").first
    @vm_options = JSON.parse(options_vms_response)
    @vm_hash = JSON.parse(get_test1_vms_response)["resources"].first
  end

  describe "resource" do
    it "responds to subcollections" do
      @vm_options["subcollections"].each do |subcollection|
        expect(@vm.respond_to?(subcollection.to_sym)).to be_truthy
      end
    end

    it "creates subcollections of correct type" do
      stub_request(:get, "#{vms_url}/#{@vm.id}/tags?hide=resources")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

      expect(@vm.tags).to be_a(described_class.subclass("tags"))
    end
  end

  describe "subcollection actions" do
    before do
      stub_request(:get, "#{vms_url}/#{@vm.id}/tags?hide=resources")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

      @tag_actions = JSON.parse(get_test1_tags_response)["actions"]
                         .select { |aspec| aspec["method"] == "post" }
                         .collect { |aspec| aspec["name"] }
    end

    it "are exposed by subcollection" do
      @tag_actions.each do |action|
        expect(@vm.tags.respond_to?(action.to_sym)).to be_truthy
      end
    end

    it "post the correct request to the resource subcollection" do
      @tag_actions.each do |action|
        stub_request(:post, "#{vms_url}/#{@vm.id}/tags")
          .with(:body => {"action" => action}, :headers => {'Content-Type' => 'application/json'})
          .to_return(:status => 200, :body => actions_vm_tags_response, :headers => {})

        @vm.tags.public_send(action.to_sym)
      end
    end

    it "post single resource to the subcollection" do
      @tag_actions.each do |action|
        stub_request(:post, "#{vms_url}/#{@vm.id}/tags")
          .with(:body    => {"action" => action, "resource" => { "id" => 11 }},
                :headers => {'Content-Type' => 'application/json'})
          .to_return(:status => 200, :body => actions_vm_tags_response, :headers => {})

        @vm.tags.public_send(action.to_sym, :id => 11)
      end
    end

    it "post multiple resources to the subcollection" do
      @tag_actions.each do |action|
        stub_request(:post, "#{vms_url}/#{@vm.id}/tags")
          .with(:body    => {"action" => action, "resources" => [{ "id" => 11 }, { "id" => 12 }]},
                :headers => {'Content-Type' => 'application/json'})
          .to_return(:status => 200, :body => actions_vm_tags_response, :headers => {})

        @vm.tags.public_send(action.to_sym, [{:id => 11}, {:id => 12}])
      end
    end
  end

  describe "get" do
    before do
      stub_request(:get, "#{vms_url}/#{@vm.id}/tags?hide=resources")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

      stub_request(:get, "#{vms_url}/#{@vm.id}/tags?expand=resources")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})
    end

    it "returns array of subresources" do
      @vm.tags.collect do |resource|
        expect(resource).to be_a(ManageIQ::API::Client::Subresource::Tag)
      end
    end

    it "returns valid set of subresources" do
      vm_tags = JSON.parse(get_test1_tags_response)["resources"]
      expect(@vm.tags.collect(&:name)).to match_array(vm_tags.collect { |tag| tag["name"] })
    end
  end

  describe "queryable" do
    let(:vm_tags_url) { "#{vms_url}/#{@vm.id}/tags" }

    before do
      stub_request(:get, "#{vm_tags_url}?hide=resources")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

      stub_request(:get, "#{vm_tags_url}?expand=resources")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

      @vm_tags = JSON.parse(get_test1_tags_response)["resources"]
    end

    it "supports select" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&attributes=name")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

      expect(@vm.tags.select(:name).collect(&:name)).to match_array(@vm_tags.collect { |tag| tag["name"] })
    end

    it "supports offset" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&offset=100")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags.offset(100).collect(&:name)
    end

    it "supports offset and limit" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&offset=100&limit=50")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags.offset(100).limit(50).collect(&:name)
    end

    it "supports where" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&filter[]=name='/managed/location/hawaii'")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags.where(:name => "/managed/location/hawaii").collect(&:name)
    end

    it "supports chainable where filters" do
      stub_request(:get, "#{vm_tags_url}?expand=resources"\
                         "&filter[]=id=200"\
                         "&filter[]=name='/managed/cost_center/test'")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags.where(:id => 200).where(:name => '/managed/cost_center/test').collect(&:name)
    end

    it "supports first" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&limit=1")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

      expect(@vm.tags.first.name).to eq(@vm_tags.first["name"])
    end

    it "supports last" do
      stub_request(:get, "#{vm_tags_url}?expand=resources")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

      expect(@vm.tags.last.name).to eq(@vm_tags.last["name"])
    end

    it "supports pluck" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&attributes=name")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

      expect(@vm.tags.pluck(:name)).to match_array(@vm_tags.collect { |tag| tag["name"] })
    end

    it "supports find" do
      tag = @vm_tags.first

      stub_request(:get, "#{vm_tags_url}?expand=resources&filter[]=id=#{tag['id']}&limit=1")
        .to_return(:status => 200, :body => get_test1_tags_response, :headers => {})

      expect(@vm.tags.find(tag['id']).name).to eq(tag['name'])
    end

    it "supports find_by" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&filter[]=name='/managed/location/bogus'&limit=1")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags.find_by(:name => "/managed/location/bogus")
    end

    it "supports order" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&sort_by=name&sort_order=asc")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags.order(:name).collect(&:name)
    end

    it "supports descending order" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&sort_by=name&sort_order=desc")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags.order(:name => "descending").collect(&:name)
    end

    it "supports multiple order" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&sort_by=category,name&sort_order=asc,asc")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags.order(:category, :name).collect(&:name)
    end

    it "supports multiple order with mixed ascending and descending" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&sort_by=category,name&sort_order=desc,asc")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags.order(:category => "descending", :name => "ascending").collect(&:name)
    end

    it "supports chainable order with mixed ascending and descending" do
      stub_request(:get, "#{vm_tags_url}?expand=resources&sort_by=category,name&sort_order=desc,asc")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags.order(:category => "DESC").order(:name => "ASC").collect(&:name)
    end

    it "supports compound chaining" do
      stub_request(:get, "#{vm_tags_url}?expand=resources"\
                         "&attributes=category,name"\
                         "&sort_by=category,name&sort_order=desc,asc"\
                         "&filter[]=name='/managed/*'&filter[]=category='location'"\
                         "&offset=100&limit=25")
        .to_return(:status => 200, :body => get_test1_no_tags_response, :headers => {})

      @vm.tags
         .select(:category, :name)
         .order(:category => "descending").order(:name)
         .where(:name => "/managed/*").where(:category => "location")
         .offset(100).limit(25)
         .collect(&:name)
    end
  end
end
