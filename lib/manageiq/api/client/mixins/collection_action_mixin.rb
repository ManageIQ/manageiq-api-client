module CollectionActionMixin
  include ActionMixin

  ACTIONS_RETURNING_RESOURCES = %w(create query).freeze

  def exec_action(name, *args, &block)
    action = find_action(name)
    body = action_body(action.name, *args, &block)
    bulk_request = body.key?("resources")
    res = client.send(action.method, URI(action.href)) { body }
    if ACTIONS_RETURNING_RESOURCES.include?(action.name) && res.key?("results")
      klass = ManageIQ::API::Client::Resource.subclass(self.name)
      res = results_to_objects(res["results"], klass)
      res = res[0] if !bulk_request && res.size == 1
    else
      res = res["results"].collect { |result| action_result(result) }
    end
    res
  end

  def results_to_objects(results, klass)
    results.collect do |resource_hash|
      if ManageIQ::API::Client::ActionResult.an_action_result?(resource_hash)
        ManageIQ::API::Client::ActionResult.new(resource_hash)
      else
        klass.new(self, resource_hash)
      end
    end
  end

  def action_body(action_name, *args, &block)
    args = args.flatten
    args = args.first if args.size == 1 && args.first.kind_of?(Hash)
    args = {} if args.blank?
    block_data = block ? block.call : {}
    body = { "action" => action_name }
    if block_data.present?
      if block_data.kind_of?(Array)
        body["resources"] = block_data.collect { |resource| resource.merge(args) }
      elsif args.present? && args.kind_of?(Array)
        body["resources"] = args.collect { |resource| resource.merge(block_data) }
      else
        body["resource"] = args.dup.merge!(block_data)
      end
    elsif args.present?
      body[args.kind_of?(Array) ? "resources" : "resource"] = args
    end
    body
  end
end
