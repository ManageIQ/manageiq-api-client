describe ManageIQ::API::Client::Authentication do
  let(:user_and_password_error) { "Must specify both a user and a password" }

  describe "#new" do
    it "does not create a new authentication with missing password" do
      expect { described_class.new(:user => "user") }.to raise_error(user_and_password_error)
    end

    it "does not create a new authentication with missing user" do
      expect { described_class.new(:password => "pass") }.to raise_error(user_and_password_error)
    end

    it "creates a new authentication with default credentials" do
      auth = described_class.new
      expect(auth.user).to eq("admin")
      expect(auth.password).to eq("smartvm")
    end

    it "creates a new authentication with default credentials and optional authorization group " do
      auth = described_class.new(:group => "super_user")
      expect(auth.user).to eq("admin")
      expect(auth.group).to eq("super_user")
    end

    it "creates a new authentication with an api token" do
      expect(described_class.new(:token => "api_token").token).to eq("api_token")
    end

    it "creates a new authentication with a system token" do
      expect(described_class.new(:miqtoken => "miq_token").miqtoken).to eq("miq_token")
    end
  end

  describe "#auth_options_specified" do
    it "returns true with credentials" do
      expect(described_class.auth_options_specified?(:user => "user", :password => "pass")).to be_truthy
    end

    it "returns true with token" do
      expect(described_class.auth_options_specified?(:token => "token")).to be_truthy
    end

    it "returns true with miqtoken" do
      expect(described_class.auth_options_specified?(:miqtoken => "miqtoken")).to be_truthy
    end

    it "returns true with group" do
      expect(described_class.auth_options_specified?(:group => "group")).to be_truthy
    end

    it "returns false with missing credentials" do
      expect(described_class.auth_options_specified?({})).to be_falsey
    end
  end
end
