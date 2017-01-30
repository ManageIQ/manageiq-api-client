describe ManageIQ::API::Client::ActionResult do
  let(:invalid_action_result_error) { "Not a valid Action Result specified" }
  let(:success_action_result) { {"success" => true, "message" => "Vm powered on"} }
  let(:failed_action_result) { {"success" => false, "message" => "Vm could not be powered on"} }

  describe ".new" do
    it "does not create an action result given an invalid hash" do
      expect { described_class.new("bogus" => "data") }.to raise_error(invalid_action_result_error)
    end

    it "does not create an action result with a missing hash" do
      expect { described_class.new(nil) }.to raise_error(invalid_action_result_error)
    end

    it "creates a new action result" do
      expect(described_class.new(success_action_result).attributes).to match(success_action_result)
    end
  end

  describe ".an_action_result?" do
    it "fails with a nil action result" do
      expect(described_class.an_action_result?(nil)).to be_falsey
    end

    it "fails with an action result missing the success element" do
      expect(described_class.an_action_result?("message" => "Rebooting Vm")).to be_falsey
    end

    it "fails with an action result missing the message element" do
      expect(described_class.an_action_result?("success" => false)).to be_falsey
    end

    it "succeeds with a valid action result" do
      expect(described_class.an_action_result?(success_action_result)).to be_truthy
    end
  end

  describe ".succeeded?" do
    it "returns true with a successful action result" do
      expect(described_class.new(success_action_result).succeeded?).to be_truthy
    end

    it "returns false with a failed action result" do
      expect(described_class.new(failed_action_result).succeeded?).to be_falsey
    end
  end

  describe ".failed?" do
    it "returns false with a successful action result" do
      expect(described_class.new(success_action_result).failed?).to be_falsey
    end

    it "returns true with a failed action result" do
      expect(described_class.new(failed_action_result).failed?).to be_truthy
    end
  end

  describe ".method_missing" do
    it "allows accessing action result success by attribute" do
      expect(described_class.new(success_action_result).success).to eq(success_action_result["success"])
    end

    it "allows accessing action result message by attribute" do
      expect(described_class.new(success_action_result).message).to eq(success_action_result["message"])
    end

    it "allows accessing any action result attribute by name" do
      alt_action_result = success_action_result.merge("opt_results" => [1, 5, 7])
      expect(described_class.new(alt_action_result).opt_results).to eq([1, 5, 7])
    end

    it "fails when accessing an invalid action result attribute" do
      expect { described_class.new(success_action_result).bogus }.to raise_error(NoMethodError)
    end
  end
end
