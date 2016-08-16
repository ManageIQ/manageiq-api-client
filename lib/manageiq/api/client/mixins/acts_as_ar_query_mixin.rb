module ActsAsArQueryMixin
  extend ActiveSupport::Concern

  def ar_query
    ManageIQ::API::Client::ActsAsArQuery.new(self)
  end

  delegate :first, :second, :third, :fourth, :fifth, :last,
           :all, :ids,
           :select, :where, :not,
           :limit, :offset, :take,
           :except, :unscope, :only,
           :order, :reorder, :reverse_order, :to => :ar_query
end
