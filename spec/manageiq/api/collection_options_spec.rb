describe ManageIQ::API::Client::CollectionOptions do
  describe ".new" do
    let(:groups_options_hash) do
      {
        "virtual_attributes" => %w(
          allocated_memory
          allocated_storage
          allocated_vcpu
          custom_1
          custom_2
          custom_3
          custom_4
          miq_user_role_name
          provisioned_storage
          read_only
          region_description
          region_number
          user_count
        ),
        "attributes"         => %w(
          created_on
          description
          group_type
          id
          sequence
          settings
          tenant_id
          updated_on
        ),
        "data"               => {
          "required_fields" => %w(id description group_type),
          "system_groups"   => {
            "EvmGroup-super_administrator" => { "sequence" => 1 },
            "EvmGroup-operator"            => { "sequence" => 2 },
            "EvmGroup-user"                => { "sequence" => 3 },
            "EvmGroup-administrator"       => { "sequence" => 4 },
            "EvmGroup-approver"            => { "sequence" => 5 }
          }
        },
        "relationships"      => %w(
          active_vms
          custom_attributes
          entitlement
          miq_custom_attributes
          miq_report_results
          miq_reports
          miq_templates
          miq_user_role
          miq_widget_contents
          miq_widget_sets
          taggings
          tags
          tenant
          users
          vms
        )
      }
    end

    it "creates a new collection options object" do
      expect(described_class.new(groups_options_hash)).to be_a(described_class)
    end

    it "allows access of collection options elements by attribute" do
      groups_options = described_class.new(groups_options_hash)
      groups_options_hash.each { |key, value| expect(groups_options.public_send(key)).to eq(value) }
    end
  end
end
