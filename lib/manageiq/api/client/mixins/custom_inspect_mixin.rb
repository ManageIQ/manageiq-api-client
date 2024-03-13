module CustomInspectMixin
  def inspect
    pretty_print_inspect
  end

  def pretty_print(q)
    q.pp_object(self)
  end

  def pretty_print_instance_variables
    super - self.class::CUSTOM_INSPECT_EXCLUSIONS
  end
end
