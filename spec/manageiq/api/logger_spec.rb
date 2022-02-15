describe ManageIQ::API::Client do
  before do
    @entrypoint_response = api_file_fixture("responses/entrypoint.json")

    stub_request(:get, "http://localhost:3000/api?attributes=authorization")
      .to_return(:status => 200, :body => @entrypoint_response, :headers => {})
  end

  after do
    described_class.instance_variable_set(:@logger, nil)
  end

  describe ".logger" do
    it "returns default logger" do
      expect(described_class.logger).to be_a(ManageIQ::API::Client::NullLogger)
    end

    it "returns client's logger" do
      miq = described_class.new

      expect(described_class.logger).to eq(miq.logger)
    end
  end

  describe ".logger=" do
    it "sets a default logger" do
      my_logger = Logger.new(nil)
      described_class.logger = my_logger

      miq = described_class.new

      expect(miq.logger).to eq(my_logger)
    end
  end

  describe ".new" do
    it "support a user specified logger" do
      my_logger = Logger.new(nil)

      miq = described_class.new(:logger => my_logger)

      expect(miq.logger).to eq(my_logger)
    end
  end
end
