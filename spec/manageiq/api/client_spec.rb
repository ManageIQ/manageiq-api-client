describe ManageIQ::API::Client do
  let(:api_url) { "http://localhost:3000/api" }
  let(:entrypoint_request_url) { "#{api_url}?attributes=authorization" }

  describe "implementation" do
    it 'declares a version number' do
      expect(ManageIQ::API::Client::VERSION).not_to be nil
    end
  end

  describe ".new" do
    before do
      @entrypoint_response = api_file_fixture("responses/entrypoint.json")
    end

    it "creates a new client" do
      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      expect(described_class.new).to be_a(described_class)
    end

    it "supports optional appliance url" do
      stub_request(:get, "https://miq_appliance.example.com/api?attributes=authorization")
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new(:url => "https://miq_appliance.example.com")

      expect(miq).to be_a(described_class)
    end

    it "rejects malformed appliance url" do
      expect { described_class.new(:url => "foo\\bar") }
        .to raise_error("Malformed ManageIQ Appliance URL foo\\bar specified")
    end

    it "supports default user authentication" do
      stub_request(:get, entrypoint_request_url)
        .with(:headers => {:authorization => 'Basic YWRtaW46c21hcnR2bQ=='})
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new

      expect(miq).to be_a(described_class)
      expect(miq.authentication.user).to     eq("admin")
      expect(miq.authentication.password).to eq("smartvm")
      expect(miq.authentication.group).to    be_nil
      expect(miq.authentication.token).to    be_nil
      expect(miq.authentication.miqtoken).to be_nil
    end

    it "supports optional user authentication" do
      stub_request(:get, entrypoint_request_url)
        .with(:headers => {:authorization => 'Basic Zm9vOmJhcg=='})
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new(:user => "foo", :password => "bar")

      expect(miq).to be_a(described_class)
      expect(miq.authentication.user).to     eq("foo")
      expect(miq.authentication.password).to eq("bar")
      expect(miq.authentication.group).to    be_nil
      expect(miq.authentication.token).to    be_nil
      expect(miq.authentication.miqtoken).to be_nil
    end

    it "supports optional user token" do
      stub_request(:get, entrypoint_request_url)
        .with(:headers => {:x_auth_token => 'user_token'})
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new(:token => "user_token")

      expect(miq).to be_a(described_class)
      expect(miq.authentication.user).to     be_nil
      expect(miq.authentication.password).to be_nil
      expect(miq.authentication.group).to    be_nil
      expect(miq.authentication.token).to    eq("user_token")
      expect(miq.authentication.miqtoken).to be_nil
    end

    it "supports optional system token" do
      stub_request(:get, entrypoint_request_url)
        .with(:headers => {:x_miq_token => 'system_token'})
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new(:miqtoken => "system_token")

      expect(miq).to be_a(described_class)
      expect(miq.authentication.user).to     be_nil
      expect(miq.authentication.password).to be_nil
      expect(miq.authentication.group).to    be_nil
      expect(miq.authentication.token).to    be_nil
      expect(miq.authentication.miqtoken).to eq("system_token")
    end

    it "supports optional authorization group" do
      stub_request(:get, entrypoint_request_url)
        .with(:headers => {:x_miq_group => 'special_group'})
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new(:group => "special_group")

      expect(miq).to be_a(described_class)
      expect(miq.authentication.user).to     eq("admin")
      expect(miq.authentication.password).to eq("smartvm")
      expect(miq.authentication.group).to    eq("special_group")
      expect(miq.authentication.token).to    be_nil
      expect(miq.authentication.miqtoken).to be_nil
    end

    it "support open_timeout and timeout" do
      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new(:open_timeout => 11, :timeout => 22)

      expect(miq.connection.handle.options.open_timeout).to eq(11)
      expect(miq.connection.handle.options.timeout).to eq(22)
    end
  end

  describe ".load_definitions" do
    before do
      @entrypoint_response = api_file_fixture("responses/entrypoint.json")
    end

    it "exposes api information" do
      entrypoint = JSON.parse(@entrypoint_response)

      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new

      expect(miq.api).to be_a(ManageIQ::API::Client::API)
      expect(miq.api.description).to         eq(entrypoint["description"])
      expect(miq.api.name).to                eq(entrypoint["name"])
      expect(miq.api.version).to             eq(entrypoint["version"])
      expect(miq.api.versions.first.name).to eq(entrypoint["versions"].first["name"])
      expect(miq.api.versions.first.href).to eq(entrypoint["versions"].first["href"])
    end

    it "exposes user_settings" do
      user_settings = JSON.parse(@entrypoint_response)["settings"]

      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new

      expect(miq.user_settings).to match(user_settings)
    end

    it "exposes identity" do
      identity = JSON.parse(@entrypoint_response)["identity"]

      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new

      expect(miq.identity).to be_a(ManageIQ::API::Client::Identity)
      expect(miq.identity.userid).to     eq(identity["userid"])
      expect(miq.identity.name).to       eq(identity["name"])
      expect(miq.identity.user_href).to  eq(identity["user_href"])
      expect(miq.identity.group).to      eq(identity["group"])
      expect(miq.identity.group_href).to eq(identity["group_href"])
      expect(miq.identity.role).to       eq(identity["role"])
      expect(miq.identity.role_href).to  eq(identity["role_href"])
      expect(miq.identity.tenant).to     eq(identity["tenant"])
      expect(miq.identity.groups).to     eq(identity["groups"])
    end

    it "exposes server_info" do
      server_info = JSON.parse(@entrypoint_response)["server_info"]

      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new

      expect(miq.server_info).to be_a(ManageIQ::API::Client::ServerInfo)
      expect(miq.server_info.appliance).to   eq(server_info["appliance"])
      expect(miq.server_info.build).to       eq(server_info["build"])
      expect(miq.server_info.version).to     eq(server_info["version"])
      expect(miq.server_info.server_href).to eq(server_info["server_href"])
      expect(miq.server_info.zone_href).to   eq(server_info["zone_href"])
      expect(miq.server_info.region_href).to eq(server_info["region_href"])
    end

    it "exposes product_info" do
      product_info = JSON.parse(@entrypoint_response)["product_info"]

      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new

      expect(miq.product_info).to be_a(ManageIQ::API::Client::ProductInfo)
      expect(miq.product_info.name).to                 eq(product_info["name"])
      expect(miq.product_info.name_full).to            eq(product_info["name_full"])
      expect(miq.product_info.copyright).to            eq(product_info["copyright"])
      expect(miq.product_info.support_website).to      eq(product_info["support_website"])
      expect(miq.product_info.support_website_text).to eq(product_info["support_website_text"])
    end
  end

  describe ".update_authentication" do
    before do
      @entrypoint_response = api_file_fixture("responses/entrypoint.json")
    end

    it "updates a client authentication and reconnects" do
      stub_request(:get, entrypoint_request_url)
        .with(:headers => {:authorization => 'Basic YWRtaW46c21hcnR2bQ=='})
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new

      expect(miq).to be_a(described_class)
      expect(miq.authentication.user).to     eq("admin")
      expect(miq.authentication.password).to eq("smartvm")
      expect(miq.authentication.group).to    be_nil
      expect(miq.authentication.token).to    be_nil
      expect(miq.authentication.miqtoken).to be_nil

      stub_request(:get, entrypoint_request_url)
        .with(:headers => {:x_auth_token => 'user_temporary_token'})
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq.update_authentication(:token => "user_temporary_token")

      expect(miq.authentication.user).to     be_nil
      expect(miq.authentication.password).to be_nil
      expect(miq.authentication.group).to    be_nil
      expect(miq.authentication.token).to    eq("user_temporary_token")
      expect(miq.authentication.miqtoken).to be_nil
    end

    it "group re-authorization updates a client's authentication and reconnects" do
      stub_request(:get, entrypoint_request_url)
        .with(:headers => {:authorization => 'Basic YWRtaW46c21hcnR2bQ==', :x_miq_group => "basic_users"})
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq = described_class.new(:group => "basic_users")

      expect(miq).to be_a(described_class)
      expect(miq.authentication.user).to     eq("admin")
      expect(miq.authentication.password).to eq("smartvm")
      expect(miq.authentication.group).to    eq("basic_users")
      expect(miq.authentication.token).to    be_nil
      expect(miq.authentication.miqtoken).to be_nil

      stub_request(:get, entrypoint_request_url)
        .with(:headers => {:authorization => 'Basic YWRtaW46c21hcnR2bQ==', :x_miq_group => "super_admins"})
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      miq.update_authentication(:group => "super_admins")

      expect(miq.authentication.user).to     eq("admin")
      expect(miq.authentication.password).to eq("smartvm")
      expect(miq.authentication.group).to    eq("super_admins")
      expect(miq.authentication.token).to    be_nil
      expect(miq.authentication.miqtoken).to be_nil
    end
  end

  describe "http primitive" do
    before do
      @entrypoint_response = api_file_fixture("responses/entrypoint.json")

      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      @miq = described_class.new
    end

    it "get is supported" do
      stub_request(:get, "#{api_url}/vms")
        .to_return(:status => 200, :body => '{"success_method": "get"}', :headers => {})

      expect(@miq.get("vms")).to eq("success_method" => "get")
    end

    it "post is supported" do
      stub_request(:post, "#{api_url}/hosts")
        .to_return(:status => 200, :body => '{"success_method": "post"}', :headers => {})

      expect(@miq.post("hosts")).to eq("success_method" => "post")
    end

    it "put is supported" do
      stub_request(:put, "#{api_url}/templates")
        .to_return(:status => 200, :body => '{"success_method": "put"}', :headers => {})

      expect(@miq.put("templates")).to eq("success_method" => "put")
    end

    it "patch is supported" do
      stub_request(:patch, "#{api_url}/instances")
        .to_return(:status => 200, :body => '{"success_method": "patch"}', :headers => {})

      expect(@miq.patch("instances")).to eq("success_method" => "patch")
    end

    it "delete is supported" do
      stub_request(:delete, "#{api_url}/vms/999")
        .to_return(:status => 200, :body => '{"success_method": "delete"}', :headers => {})

      expect(@miq.delete("vms/999")).to eq("success_method" => "delete")
    end

    it "options is supported" do
      stub_request(:options, "#{api_url}/groups")
        .to_return(:status => 200, :body => '{"success_method": "options"}', :headers => {})

      expect(@miq.options("groups")).to eq("success_method" => "options")
    end
  end

  describe "Errors" do
    before do
      @entrypoint_response = api_file_fixture("responses/entrypoint.json")

      stub_request(:get, entrypoint_request_url)
        .to_return(:status => 200, :body => @entrypoint_response, :headers => {})

      @miq = described_class.new
    end

    it "are properly raised for routing errors" do
      error_response_json = api_file_fixture("responses/error_routing.json")

      stub_request(:get, "#{api_url}/bogus_collection")
        .to_return(:status => 404, :body => error_response_json, :headers => {})

      error_response = JSON.parse(error_response_json)
      expect { @miq.get("bogus_collection") }.to raise_error(error_response["error"])
    end

    it "are properly raised for API errors" do
      error_response_json = api_file_fixture("responses/error_vms_9999_not_found.json")

      stub_request(:get, "#{api_url}/vms/9999")
        .to_return(:status => 404, :body => error_response_json, :headers => {})

      error_response = JSON.parse(error_response_json)
      expect { @miq.get("vms/9999") }.to raise_error(error_response["error"]["message"])
    end
  end
end
