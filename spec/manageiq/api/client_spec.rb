require 'spec_helper'

describe ManageIQ::Api::Client do
  it 'has a version number' do
    expect(ManageIQ::Api::Client::VERSION).not_to be nil
  end
end
