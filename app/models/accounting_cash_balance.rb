class AccountingCashBalance < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10
  belongs_to :accounting_transaction_type, :foreign_key => :transaction_type_id
  belongs_to :payment_procedure, :foreign_key => :payment_procedure_id
  belongs_to :accounting_account, :foreign_key => :account_id
  belongs_to :contra_account, :class_name => 'AccountingAccount', :foreign_key => :contra_account_id

  attr_accessor :account_code, :cash_book, :without_calculation

  validates_presence_of :transaction_value, :description
  validates_numericality_of :transaction_value

  before_create :handle_cash_book
  before_save  :get_old_cash_balance
  before_update :handle_cash_book_update
  before_destroy :get_old_cash_balance

  def after_save
    sum_cash_balance
  end

  def after_destroy
    #sum_cash_balance
  end

  ## Handle get condition data
  def self.get_first_cash_data(options = {})
    AccountingCashBalance.with_dynamic_time(options[:month], options[:year]) do
      AccountingCashBalance.find(:first, :conditions => ["transaction_type_id = 1"])
    end
  end

  def self.get_first_payment_data(options = {})
    AccountingCashBalance.with_dynamic_time(options[:month], options[:year]) do
      AccountingCashBalance.find(:first, :conditions => ["transaction_type_id <> 1"])
    end
  end

  def self.get_first_cash_balance(options = {})
    AccountingCashBalance.with_dynamic_time(options[:month], options[:year]) do
      AccountingCashBalance.find(:first, :conditions => ["transaction_type_id = 1 OR transaction_type_id <> 1"])
    end
  end

  def self.get_first_by_transaction_type(options = {})
    AccountingCashBalance.with_dynamic_time(options[:month], options[:year]) do
      AccountingCashBalance.find(:first, :conditions => ["transaction_type_id = ?", options[:transaction_type_id]])
    end
  end

  def self.get_latest_cash_book(options = {})
    AccountingCashBalance.with_dynamic_time(options[:month], options[:year]) do
      AccountingCashBalance.find(:first, :conditions => ["#{options[:type]} IS NOT NULL"], :order => "CAST(#{options[:type]} as UNSIGNED INT) DESC")
    end
  end

  ## Handle dafault condition
  def self.with_current_time
    current_month = Time.now.strftime("%m")
    current_year = Time.now.strftime("%Y")
    with_scope :find => { :conditions => ["MONTH(created_at) = ? AND YEAR(created_at) = ?", current_month, current_year] } do
      yield
    end
  end

  def self.find_with_current_time(*args)
    with_current_time {find(*args)}
  end

  def self.with_dynamic_time(month, year)
    with_scope :find => { :conditions => ["MONTH(created_at) = ? AND YEAR(created_at) = ?", month, year] } do
      yield
    end
  end

  def handle_cash_book
    get_creation_date
    if cash_book == "bkk"
      prepare_cash_book_handling("bkk")
      self.bkk, self.bkm = @next_code, nil
    elsif cash_book == "bkm"
      prepare_cash_book_handling("bkm")
      self.bkm, self.bkk = @next_code, nil
    end
  end

  private

  def prepare_cash_book_handling(option)
    two_digit_month = self.created_at.strftime('%m')
    latest = AccountingCashBalance.get_latest_cash_book(:type => option,:month => @created_month, :year => @created_year)
    if latest
      size = latest.send(option).size - 2
      next_code = latest.send(option).slice(0..(size - 1)).to_i + 1
      @next_code = "#{next_code}#{two_digit_month}"
    else
      @next_code = "1#{two_digit_month}"
    end
  end

  def handle_cash_book_update
    get_creation_date
    if cash_book == "bkk" && self.bkk.nil?
      prepare_cash_book_handling("bkk")
      self.bkk, self.bkm = @next_code, nil
    elsif cash_book == "bkk" && self.bkk != nil
      self.bkk, self.bkm = self.bkk, nil
    elsif cash_book == "bkm" && self.bkm.nil?
      prepare_cash_book_handling("bkm")
      self.bkm, self.bkk = @next_code, nil
    elsif cash_book == "bkm" && self.bkm != nil
      self.bkk, self.bkm = nil, self.bkm
    end
  end

  def sum_cash_balance
    if @@do_after_save && (without_calculation != true)
      get_creation_date
      @one_month_ago_cash_balance = AccountingCashBalance.accumulate_one_month_ago_cash_balance(@created_month, @created_year)

      AccountingCashBalance.with_dynamic_time(@created_month, @created_year) do
        now_cash_balance = AccountingCashBalance.accumulate_cash_balance(@created_month, @created_year)
        cash_balance = @one_month_ago_cash_balance + now_cash_balance
        AccountingCashBalance.update_all("cash_balance = #{cash_balance}")
        @cash_balance = cash_balance
      end

      update_all_cash_balances(@cash_balance)
    end
  end

  def self.accumulate_total_revenue(month, year)
    AccountingCashBalance.with_dynamic_time(month, year) do
      @total_revenue = AccountingCashBalance.sum("transaction_value", :conditions => "bkm IS NOT NULL")
    end
    accumulate_one_month_ago_cash_balance(month, year) + @total_revenue
  end

  def self.accumulate_total_payment(month, year)
    AccountingCashBalance.with_dynamic_time(month, year) do
      @total_payment = AccountingCashBalance.sum("transaction_value", :conditions => "bkk IS NOT NULL")
    end
  end
  
  def self.accumulate_total_payment(month, year)
    AccountingCashBalance.with_dynamic_time(month, year) do
      @total_payment = AccountingCashBalance.sum("transaction_value", :conditions => "bkk IS NOT NULL")
    end
  end

  def self.accumulate_cash_balance(month, year)
    accumulate_total_revenue(month, year) - accumulate_total_payment(month, year)
  end

  def self.accumulate_one_month_ago_cash_balance(month, year)
    date = Time.mktime(year, month, 1, 0, 0, 0, 0)
    @one_month_ago = previous_current_month(date).strftime("%m")
    @one_year_ago = previous_current_month(date).strftime("%Y")

    AccountingCashBalance.with_dynamic_time(@one_month_ago, @one_year_ago) do
      @data = AccountingCashBalance.find(:first)
      @one_month_ago_cash_balance = @data ? @data.cash_balance : 0
    end
    @one_month_ago_cash_balance = @one_month_ago_cash_balance
  end

  def update_all_cash_balances(new_cash_balance)
    #get latest transaction

    latest_transaction = AccountingCashBalance.find(:first, :order => "created_at DESC").created_at
    current_transaction = self.created_at
    mon_int = month_interval(current_transaction, latest_transaction)

    @diff_cash_balance = new_cash_balance - @@old_cash_balance
    @@old_cash_balance = nil

    @@do_after_save = false
    1.upto(mon_int) do |x|
      selected_transaction = current_transaction.beginning_of_month.months_since(x)
      month = selected_transaction.strftime("%m")
      year = selected_transaction.strftime("%Y")
      AccountingCashBalance.with_dynamic_time(month, year) do
        AccountingCashBalance.find(:all).each do |data|
          data.update_attribute(:cash_balance, data.cash_balance + @diff_cash_balance)
        end
      end
    end
    @@do_after_save = true
  end

  # get month interval
  # then we can get month using
  # Time.now.beginning_of_month.months_since(x)
  def month_interval(first, second)
    mon_interval = second.mon - first.mon
    year_interval = second.year - first.year
    if mon_interval == 0 && year_interval == 0
      month_interval = 0
    else
      month_interval = (year_interval * 12) + mon_interval
    end
  end

  def get_old_cash_balance
    get_creation_date
    AccountingCashBalance.with_dynamic_time(@created_month, @created_year) do
      @old_cash_balance = AccountingCashBalance.find(:first) ? AccountingCashBalance.find(:first).cash_balance : 0
    end
    @@old_cash_balance = @old_cash_balance
  end

  def get_creation_date
    @created_month, @created_year = created_at.strftime("%m"), created_at.strftime("%Y")
  end

  def self.previous_current_month(date)
    #    date.beginning_of_month.months_ago(1)
    date.beginning_of_month.months_ago(1)
  end
end
