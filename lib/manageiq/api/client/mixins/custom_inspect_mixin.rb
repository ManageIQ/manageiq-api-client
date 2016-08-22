module CustomInspectMixin
  extend ActiveSupport::Concern

  def inspect
    res = "#{Kernel.instance_method(:to_s).bind(self).call.chomp!('>')} "
    attrs = instance_variables - custom_inspect_exclusions
    res << attrs.map { |attr| "#{attr}=#{custom_inspect_value(attr)}" }.join(", ") << ">"
  end

  private

  def custom_inspect_exclusions
    self.class.const_defined?(:CUSTOM_INSPECT_EXCLUSIONS) ? self.class::CUSTOM_INSPECT_EXCLUSIONS : []
  end

  def custom_inspect_value(attr)
    value = instance_variable_get(attr)
    case value
    when nil, String, Array, Hash then value.inspect
    else Kernel.instance_method(:to_s).bind(value).call.sub(">", " ...>")
    end
  end
end
