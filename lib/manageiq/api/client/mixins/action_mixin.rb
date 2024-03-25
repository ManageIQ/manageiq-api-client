module ActionMixin
  private

  def clear_actions
    @actions = []
  end

  def actions_present?
    !@actions.empty?
  end

  def fetch_actions(resource_hash)
    @actions = Array(resource_hash["actions"]).collect { |action| ManageIQ::API::Client::Action.new(action) }
  end

  def find_action(action)
    action_str = action.to_s
    @actions.detect { |a| a.name == action_str } if @actions
  end

  def action_defined?(action)
    find_action(action)
  end

  def actions=(action_array)
    @actions = (action_array.nil? || action_array.empty?) ? [] : action_array
  end

  def add_action(action)
    @actions << action
  end

  def action_result(hash)
    ManageIQ::API::Client::ActionResult.an_action_result?(hash) ? ManageIQ::API::Client::ActionResult.new(hash) : hash
  end
end
