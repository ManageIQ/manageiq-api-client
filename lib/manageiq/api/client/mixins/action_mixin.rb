module ActionMixin
  extend ActiveSupport::Concern

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
