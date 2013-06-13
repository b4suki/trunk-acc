class AccountingDollarBalance < ActiveRecord::Base
#  validates_numericality_of :kurs, :total_revenue, :total_payment
  attr_accessor :without_calculation

  before_save  :get_old_dollar_balance
  before_destroy :get_old_dollar_balance

  def after_save
    sum_dollar_balance
  end

  def after_destroy
    sum_dollar_balance
  end

  def self.with_dynamic_time(month, year)
    with_scope :find => { :conditions => ["MONTH(transaction_date) = ? AND YEAR(transaction_date) = ?", month, year] } do
      yield
    end
  end

  def sum_dollar_balance
    if @@do_after_save && (without_calculation != true)
      get_creation_date
      @one_month_ago_dollar_balance = AccountingDollarBalance.accumulate_one_month_ago_dollar_balance(@created_month, @created_year)

      AccountingDollarBalance.with_dynamic_time(@created_month, @created_year) do
        now_dollar_balance = AccountingDollarBalance.accumulate_dollar_balance(@created_month, @created_year)
        dollar_balance = @one_month_ago_dollar_balance + now_dollar_balance
        AccountingDollarBalance.update_all("dollar_balance = #{dollar_balance}")
        @dollar_balance = dollar_balance
      end

      update_all_dollar_balances(@dollar_balance)
    end
  end

  def update_all_dollar_balances(new_dollar_balance)
    #get latest transaction

    latest_transaction = AccountingDollarBalance.find(:first, :order => "created_at DESC").created_at
    current_transaction = self.created_at
    mon_int = month_interval(current_transaction, latest_transaction)

    @diff_dollar_balance = new_dollar_balance - @@old_dollar_balance
    @@old_dollar_balance = nil

    @@do_after_save = false
    1.upto(mon_int) do |x|
      selected_transaction = current_transaction.beginning_of_month.months_since(x)
      month = selected_transaction.strftime("%m")
      year = selected_transaction.strftime("%Y")
      AccountingDollarBalance.with_dynamic_time(month, year) do
        AccountingDollarBalance.find(:all).each do |data|
          data.update_attribute(:dollar_balance, data.dollar_balance + @diff_dollar_balance)
        end
      end
    end
    @@do_after_save = true
  end

  def month_interval(first, second)
    mon_interval = second.mon - first.mon
    year_interval = second.year - first.year
    if mon_interval == 0 && year_interval == 0
      month_interval = 0
    else
      month_interval = (year_interval * 12) + mon_interval
    end
  end
  
  def self.accumulate_one_month_ago_dollar_balance(month, year)
    date = Time.mktime(year, month, 1, 0, 0, 0, 0)
    @one_month_ago = previous_current_month(date).strftime("%m")
    @one_year_ago = previous_current_month(date).strftime("%Y")

    AccountingDollarBalance.with_dynamic_time(@one_month_ago, @one_year_ago) do
      @data = AccountingDollarBalance.find(:first, :order => :created_at)
      @one_month_ago_dollar_balance = @data ? @data.dollar_balance : 0
    end
    @one_month_ago_dollar_balance = @one_month_ago_dollar_balance
  end
  
  def self.accumulate_total_revenue(month, year)
    AccountingDollarBalance.with_dynamic_time(month, year) do
      @total_revenue = AccountingDollarBalance.sum("total_revenue")
    end
  end

  def self.accumulate_total_payment(month, year)
    AccountingDollarBalance.with_dynamic_time(month, year) do
      @total_payment = AccountingDollarBalance.sum("total_payment")
    end
  end

  def self.accumulate_dollar_balance(month, year)
    accumulate_total_revenue(month, year) - accumulate_total_payment(month, year)
  end

  def self.accumulate_total_dollar_balance(month, year)
    accumulate_one_month_ago_dollar_balance(month, year) + accumulate_total_revenue(month, year) - accumulate_total_payment(month, year)
  end

  def get_old_dollar_balance
    get_creation_date
    AccountingDollarBalance.with_dynamic_time(@created_month, @created_year) do
      @old_dollar_balance = AccountingDollarBalance.find(:first) ? AccountingDollarBalance.find(:first).dollar_balance : 0
    end
    @@old_dollar_balance = @old_dollar_balance
  end

  def get_creation_date
    @created_month, @created_year = Time.now.strftime("%m"), Time.now.strftime("%Y")
  end
  
  def self.previous_current_month(date)
    date.beginning_of_month.months_ago(1)
  end
end
