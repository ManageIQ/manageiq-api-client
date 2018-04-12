module ManageIQ::API::Client::ResourceActionMixin
  include ManageIQ::API::Client::ActionMixin

  private

  def exec_action(name, args = nil, &block)
    args ||= {}
    raise "Action #{name} parameters must be a hash" if !args.kind_of?(Hash)
    action = find_action(name)
    res = client.send(action.method, URI(action.href)) do
      body = { "action" => action.name }
      resource = args.dup
      resource.merge!(block.call) if block
      resource.present? ? body.merge("resource" => resource) : body
    end
    action_result(res)
  end

  def reload_actions
    return unless attributes.key?("href")
    resource_href = client.connection.api_path(attributes["href"].split('/').last(2).join('/'))
    resource_hash = client.get(resource_href)
    @attributes = resource_hash.except("actions")
    fetch_actions(resource_hash)
  end
end
