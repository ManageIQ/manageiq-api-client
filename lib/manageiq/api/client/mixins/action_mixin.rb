module ActionMixin
  extend ActiveSupport::Concern

  private

  def clear_actions
    @actions = []
  end

  def actions_present?
    @actions.present? if @actions
  end

  def fetch_actions(resource_hash)
    @actions = Array(resource_hash["actions"]).collect { |action| ManageIQ::API::Client::Action.new(action) }
  end

  def find_action(action)
    @actions.detect { |a| a.name == action.to_s } if @actions
  end

  def action_defined?(action)
    find_action(action) ? true : false
  end

  def actions=(action_array)
    @actions = action_array.blank? ? [] : action_array
  end

  def add_action(action)
    @actions << action
  end

  def action_result(hash)
    ManageIQ::API::Client::ActionResult.an_action_result?(hash) ? ManageIQ::API::Client::ActionResult.new(hash) : hash
  end
end
