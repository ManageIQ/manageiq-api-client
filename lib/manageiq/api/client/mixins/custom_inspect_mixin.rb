module CustomInspectMixin
  extend ActiveSupport::Concern

  DEFAULT_CUSTOM_INSPECT_EXCLUSIONS = [:@custom_inspect_exclusions].freeze

  def inspect
    res = "#<#{self.class.name}:#{object_id} "
    attrs = instance_variables - DEFAULT_CUSTOM_INSPECT_EXCLUSIONS - custom_inspect_exclusions
    fields = attrs.map { |attr| "#{attr}=#{custom_inspect_value(attr)}" }
    res << fields.join(", ") << ">"
  end

  private

  def custom_inspect_value(attr)
    value = instance_variable_get(attr)
    return "nil" if value.nil?
    return "\"#{value}\"" if value.kind_of?(String)
    return value if value.kind_of?(Hash) || value.kind_of?(Array)
    "#<#{value.class.name}:#{value.object_id} ...>"
  end

  def custom_inspect_exclude(*args)
    @custom_inspect_exclusions = Array(args).map { |attr| "@#{attr}".to_sym }
  end

  def custom_inspect_exclusions
    @custom_inspect_exclusions ||= []
  end
end
