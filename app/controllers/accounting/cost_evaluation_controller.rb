class Accounting::CostEvaluationController < ApplicationController
  before_filter :initial_method

  def index
    @accounts = AccountingAccount.find(:all, :conditions => ["parent_id is NULL"], :order => "code ASC")
  end

  private

  def initial_method
    @title = "COST EVALUATION"
    @periode = true
  end
end
