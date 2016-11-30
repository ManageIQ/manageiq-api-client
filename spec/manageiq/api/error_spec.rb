describe ManageIQ::API::Client::Error do
  let(:bad_request_error) do
    {
      :status   => 400,
      :response => {
        "error" => {
          "kind"    => "bad_request",
          "message" => "attribute foo does not exist",
          "klass"   => "Api::BadRequestError"
        }
      }
    }
  end

  let(:not_found_error) do
    {
      :status   => 404,
      :response => {
        "error" => {
          "kind"    => "not_found",
          "message" => "Couldn't find Vm with 'id'=12000",
          "klass"   => "ActiveRecord::RecordNotFound"
        }
      }
    }
  end

  describe ".new" do
    it "creates a new error object" do
      expect(described_class.new(bad_request_error[:status], bad_request_error[:response])).to be_a(described_class)
    end

    it "error object has attribute accessible elements" do
      error = described_class.new(not_found_error[:status], not_found_error[:response])
      not_found_error[:response]["error"].each { |key, value| expect(error.public_send(key)).to eq(value) }
    end
  end

  describe ".clear" do
    it "clears an error" do
      error = described_class.new(not_found_error[:status], not_found_error[:response])
      error.clear

      expect(error.status).to  eq(0)
      expect(error.kind).to    be_nil
      expect(error.message).to be_nil
      expect(error.klass).to   be_nil
    end
  end

  describe ".update" do
    it "updates an error" do
      error = described_class.new(not_found_error[:status], not_found_error[:response])
      error.update(bad_request_error[:status], bad_request_error[:response])

      bad_request_response_error = bad_request_error[:response]["error"]

      expect(error.status).to  eq(bad_request_error[:status])
      expect(error.kind).to    eq(bad_request_response_error["kind"])
      expect(error.message).to eq(bad_request_response_error["message"])
      expect(error.klass).to   eq(bad_request_response_error["klass"])
    end

    it "clears an error with success response" do
      error = described_class.new(not_found_error[:status], not_found_error[:response])
      error.update(200, "results" => [])

      expect(error.status).to  eq(200)
      expect(error.kind).to    be_nil
      expect(error.message).to be_nil
      expect(error.klass).to   be_nil
    end
  end
end
