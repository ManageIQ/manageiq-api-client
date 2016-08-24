module ActionMixin
  extend ActiveSupport::Concern

  private
  def find_action(name)
    @action = @actions.find { |action| action.name == name.to_s }
  end

  def do_action(name, *args)
    if args.any? && (args.length > 1 || !args.first.is_a?(Hash))
      raise 'TypeError: Wrong format of resource params'
    end

    @action ||= find_action(name)
    client.send @action.method, URI(@action.href) do
      body = { action: @action.name }
      body.merge!({ resource: args.first }) unless args.empty?
      body
    end
  end

  def clear_actions
    @actions = []
  end

  def fetch_actions(resource_hash)
    @actions = Array(resource_hash["actions"]).collect { |action| ManageIQ::API::Client::Action.new(action) }
  end

  def actions=(action_array)
    @actions = action_array.blank? ? [] : action_array
  end

  def add_action(action)
    @actions << action
  end
end
