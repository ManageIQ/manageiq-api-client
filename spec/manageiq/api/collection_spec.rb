describe ManageIQ::API::Client::Collection do
  let(:api_url)                     { "http://localhost:3000/api" }
  let(:groups_url)                  { "#{api_url}/groups" }
  let(:single_group_query_url)      { "#{api_url}/groups?limit=1" }
  let(:vms_url) { "#{api_url}/vms" }
  let(:vms_expand_url) { "#{vms_url}?expand=resources" }
  let(:entrypoint_request_url)      { "#{api_url}?attributes=authorization" }
  let(:single_group_query_response) { api_file_fixture("responses/single_group_query.json") }

  let(:entrypoint_response)         { api_file_fixture("responses/entrypoint.json") }
  let(:get_vms_response)            { api_file_fixture("responses/get_vms.json") }
  let(:get_no_vms_response)         { api_file_fixture("responses/get_no_vms.json") }
  let(:query_dev_vms_response)      { api_file_fixture("responses/query_dev_vms.json") }

  let(:options_groups_response)     { api_file_fixture("responses/options_groups.json") }
  let(:options_vms_response)        { api_file_fixture("responses/options_vms.json") }

  describe ".new" do
    it "client creates collections" do
      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => entrypoint_response, :headers => {})

      miq = ManageIQ::API::Client.new
      collections = JSON.parse(entrypoint_response)["collections"]
      collection_names = collections.collect { |cspec| cspec["name"] }
      expect(miq.collections.collect(&:name)).to match_array(collection_names)

      miq.collections.each do |collection|
        klass = "#{described_class}::#{collection.name.camelize}".constantize
        expect(collection).to be_a(klass)
      end
    end
  end

  describe "actions" do
    before do
      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => entrypoint_response, :headers => {})
    end

    it "fetch a single resource for getting collection actions" do
      stub_request(:get, single_group_query_url)
        .to_return(:status => 200, :body => single_group_query_response, :headers => {})

      stub_request(:post, groups_url)
        .with(:body    => {"action" => "create", "resource" => { "description" => "sample group" }},
              :headers => {'Content-Type' => 'application/json' })
        .to_return(:status => 200, :body => api_file_fixture("responses/sample_group_create.json"), :headers => {})

      miq = ManageIQ::API::Client.new
      miq.groups.create(:description => "sample group")

      stub_request(:get, vms_expand_url)
        .to_return(:status => 200, :body => get_vms_response, :headers => {})

      @vms_hash = JSON.parse(get_vms_response)
    end

    it "exposed by new collection" do
      miq = ManageIQ::API::Client.new
      vms = miq.vms

      @vms_hash["actions"].each do |aspec|
        if aspec["method"] == "post"
          expect(vms.respond_to?(aspec["name"].to_sym)).to be_truthy
        end
      end
    end

    it "supported by collection" do
      action = @vms_hash["actions"].detect { |aspec| aspec["method"] == "post" && aspec["name"] != "query" }

      stub_request(:post, vms_url)
        .with(:body => {"action" => action["name"]}, :headers => {'Content-Type' => 'application/json'})
        .to_return(:status => 200, :body => query_dev_vms_response, :headers => {})

      miq = ManageIQ::API::Client.new
      miq.vms.public_send(action["name"])
    end

    it "supported for single resources" do
      action = @vms_hash["actions"].detect { |aspec| aspec["method"] == "post" }
      vm_id = @vms_hash["resources"].first["id"]

      stub_request(:post, vms_url)
        .with(:body    => {"action" => action["name"], "resource" => { "id" => vm_id }},
              :headers => {'Content-Type' => 'application/json'})
        .to_return(:status => 200, :body => query_dev_vms_response, :headers => {})

      miq = ManageIQ::API::Client.new
      miq.vms.public_send(action["name"], :id => vm_id)
    end

    it "supported for multiple resources" do
      action = @vms_hash["actions"].detect { |aspec| aspec["method"] == "post" }
      vm_ids = @vms_hash["resources"][0, 3].collect { |vm| vm["id"] }
      vm_resources = vm_ids.collect { |id| { "id" => id, "parameter" => "value" } }

      stub_request(:post, vms_url)
        .with(:body    => {"action" => action["name"], "resources" => vm_resources},
              :headers => {'Content-Type' => 'application/json'})
        .to_return(:status => 200, :body => query_dev_vms_response, :headers => {})

      miq = ManageIQ::API::Client.new
      miq.vms.public_send(action["name"], vm_resources)
    end
  end

  describe "options" do
    let(:group_options_hash) { JSON.parse(options_groups_response) }

    it "are exposed for collections" do
      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => entrypoint_response, :headers => {})

      stub_request(:options, groups_url)
        .to_return(:status => 200, :body => options_groups_response, :headers => {})

      miq = ManageIQ::API::Client.new
      group_options = miq.groups.options

      expect(group_options.attributes).to         match_array(group_options_hash['attributes'])
      expect(group_options.virtual_attributes).to match_array(group_options_hash['virtual_attributes'])
      expect(group_options.relationships).to      match_array(group_options_hash['relationships'])
      expect(group_options.subcollections).to     match_array(group_options_hash['subcollections'])
      expect(group_options.data).to               eq(group_options_hash['data'])
    end
  end

  describe "get" do
    it "returns array of resources" do
      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => entrypoint_response, :headers => {})

      stub_request(:get, vms_expand_url)
        .to_return(:status => 200, :body => get_vms_response, :headers => {})

      miq = ManageIQ::API::Client.new
      miq.vms.get.collect do |resource|
        expect(resource).to be_a(ManageIQ::API::Client::Resource::Vm)
      end
    end

    it "returns valid set of resources" do
      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => entrypoint_response, :headers => {})

      stub_request(:get, vms_expand_url)
        .to_return(:status => 200, :body => get_vms_response, :headers => {})

      miq = ManageIQ::API::Client.new
      vms_hash = JSON.parse(get_vms_response)

      expect(miq.vms.collect(&:name)).to match_array(vms_hash["resources"].collect { |vm| vm["name"] })
    end
  end

  describe "queryable" do
    let(:vms_test1_response) { api_file_fixture("responses/get_test1_vms.json") }

    before do
      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => entrypoint_response, :headers => {})

      stub_request(:options, vms_url)
        .to_return(:status => 200, :body => options_vms_response, :headers => {})

      @miq = ManageIQ::API::Client.new
    end

    it "supports select" do
      stub_request(:get, "#{vms_expand_url}&attributes=name")
        .to_return(:status => 200, :body => get_vms_response, :headers => {})

      vm_names = JSON.parse(get_vms_response)["resources"].collect { |vm| vm["name"] }

      expect(@miq.vms.select(:name).collect(&:name)).to match_array(vm_names)
    end

    it "supports offset" do
      stub_request(:get, "#{vms_expand_url}&offset=100")
        .to_return(:status => 200, :body => get_no_vms_response, :headers => {})

      @miq.vms.offset(100).collect(&:name)
    end

    it "supports offset and limit" do
      stub_request(:get, "#{vms_expand_url}&offset=100&limit=50")
        .to_return(:status => 200, :body => get_no_vms_response, :headers => {})

      @miq.vms.offset(100).limit(50).collect(&:name)
    end

    it "supports where" do
      stub_request(:get, "#{vms_expand_url}&filter[]=name='aab-test1'")
        .to_return(:status => 200, :body => vms_test1_response, :headers => {})

      expect(@miq.vms.where(:name => "aab-test1").collect(&:name).first).to eq("aab-test1")
    end

    it "supports chainable where filters" do
      stub_request(:get, "#{vms_expand_url}"\
                         "&filter[]=name='bad-dev'"\
                         "&filter[]=memory_shares=8192"\
                         "&filter[]=power_state=nil")
        .to_return(:status => 200, :body => get_no_vms_response, :headers => {})

      @miq.vms.where(:name => "bad-dev").where(:power_state => 'nil').where(:memory_shares => 8192).collect(&:name)
    end

    it "supports first" do
      stub_request(:get, "#{vms_expand_url}&filter[]=name='aab-test1'&limit=1")
        .to_return(:status => 200, :body => vms_test1_response, :headers => {})

      expect(@miq.vms.where(:name => "aab-test1").first.name).to eq("aab-test1")
    end

    it "supports last" do
      stub_request(:get, vms_expand_url)
        .to_return(:status => 200, :body => get_vms_response, :headers => {})

      vms = JSON.parse(get_vms_response)["resources"]
      vm_names = vms.collect { |vm| vm["name"] }

      expect(@miq.vms.last.name).to eq(vm_names.last)
    end

    it "supports pluck" do
      stub_request(:get, "#{vms_expand_url}&attributes=guid")
        .to_return(:status => 200, :body => get_vms_response, :headers => {})

      vms = JSON.parse(get_vms_response)["resources"]
      vm_guids = vms.collect { |vm| vm["guid"] }

      expect(@miq.vms.pluck(:guid)).to match_array(vm_guids)
    end

    it "supports find" do
      vms_dev2_response = api_file_fixture("responses/get_dev2_vms.json")
      dev2_vm = JSON.parse(vms_dev2_response)["resources"].first
      dev2_id = dev2_vm["id"]

      stub_request(:get, "#{vms_expand_url}&filter[]=id=#{dev2_id}&limit=1")
        .to_return(:status => 200, :body => vms_dev2_response, :headers => {})

      expect(@miq.vms.find(dev2_vm["id"]).name).to eq("aab-dev2")
    end

    it "supports find with multiple ids" do
      dev_vms = JSON.parse(query_dev_vms_response)["results"]
      dev_ids = dev_vms.collect { |vm| vm["id"] }
      dev_names = dev_vms.collect { |vm| vm["name"] }

      stub_request(:get, vms_expand_url)
        .to_return(:status => 200, :body => get_vms_response, :headers => {})

      stub_request(:post, vms_url)
        .with(:body    => {"action" => "query", "resources" => dev_ids.collect { |id| { "id" => id } }},
              :headers => {'Content-Type' => 'application/json'})
        .to_return(:status => 200, :body => query_dev_vms_response, :headers => {})

      expect(@miq.vms.find(dev_ids).collect(&:name)).to match_array(dev_names)
    end

    it "supports find_by" do
      stub_request(:get, "#{vms_expand_url}&filter[]=name='aab-test1'&limit=1")
        .to_return(:status => 200, :body => vms_test1_response, :headers => {})

      expect(@miq.vms.find_by(:name => "aab-test1").name).to eq("aab-test1")
    end

    it "supports order" do
      stub_request(:get, "#{vms_expand_url}&sort_by=name&sort_order=asc")
        .to_return(:status => 200, :body => get_no_vms_response, :headers => {})

      @miq.vms.order(:name).collect(&:name)
    end

    it "supports descending order" do
      stub_request(:get, "#{vms_expand_url}&sort_by=name&sort_order=desc")
        .to_return(:status => 200, :body => get_no_vms_response, :headers => {})

      @miq.vms.order(:name => "descending").collect(&:name)
    end

    it "supports multiple order" do
      stub_request(:get, "#{vms_expand_url}&sort_by=name,vendor&sort_order=asc,asc")
        .to_return(:status => 200, :body => get_no_vms_response, :headers => {})

      @miq.vms.order(:name, :vendor).collect(&:name)
    end

    it "supports multiple order with mixed ascending and descending" do
      stub_request(:get, "#{vms_expand_url}&sort_by=name,vendor&sort_order=asc,desc")
        .to_return(:status => 200, :body => get_no_vms_response, :headers => {})

      @miq.vms.order(:name => "ascending", :vendor => "descending").collect(&:name)
    end

    it "supports chainable order with mixed ascending and descending" do
      stub_request(:get, "#{vms_expand_url}&sort_by=name,vendor&sort_order=desc,asc")
        .to_return(:status => 200, :body => get_no_vms_response, :headers => {})

      @miq.vms.order(:name => "DESC").order(:vendor => "ASC").collect(&:name)
    end

    it "supports compound chaining" do
      stub_request(:get, "#{vms_expand_url}"\
                         "&attributes=name,vendor,guid,power_state"\
                         "&sort_by=name,vendor&sort_order=asc,desc"\
                         "&filter[]=name='prod*'&filter[]=memory_shares=4096"\
                         "&offset=100&limit=25")
        .to_return(:status => 200, :body => get_no_vms_response, :headers => {})

      @miq.vms
          .select(:name, :vendor, :guid, :power_state)
          .order(:name).order(:vendor => "descending")
          .where(:name => "prod*").where(:memory_shares => 4096)
          .offset(100).limit(25)
          .collect(&:name)
    end
  end
end
