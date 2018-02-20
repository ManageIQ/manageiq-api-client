describe ManageIQ::API::Client::Collection do
  let(:api_url)                     { "http://localhost:3000/api" }
  let(:entrypoint_request_url)      { "#{api_url}?attributes=authorization" }
  let(:groups_url)                  { "#{api_url}/groups" }
  let(:single_group_query_url)      { "#{api_url}/groups?limit=1" }

  let(:entrypoint_response)         { api_file_fixture("responses/entrypoint.json") }
  let(:single_group_query_response) { api_file_fixture("responses/single_group_query.json") }

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
    end
  end
end
