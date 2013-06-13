class AccountingSaleDebitCreditValue < ActiveRecord::Base
  belongs_to :accounting_sale_balance, :foreign_key => 'sale_balance_id'
  belongs_to :accounting_sale_debit_credit, :foreign_key => 'sale_debit_credit_id'
  belongs_to :account, :class_name => "AccountingAccount", :foreign_key => "account_id"
  
  def after_create 
     # sum_total_debit_credit('create')    
  end
  
  def before_update
    if @@do_after_save
     # sum_total_debit_credit('update')    
    end
  end
  
  def before_destroy
    if @@do_after_save
     # sum_total_debit_credit('delete')    
    end
  end
  
  def sum_total_debit_credit(action)
    get_creation_date
    AccountingSaleDebitCreditValue.with_dynamic_time(@created_month, @created_year) do
      @first_data = AccountingSaleDebitCreditValue.find(:first, :conditions => ["sale_debit_credit_id = ?",sale_debit_credit_id])      
      @selected_data = AccountingSaleDebitCreditValue.find(:first, :conditions => ["sale_debit_credit_id = ? and id = ?",sale_debit_credit_id,id])
      @all_data = AccountingSaleDebitCreditValue.find(:all, :conditions => ["sale_debit_credit_id = ?", sale_debit_credit_id])
    end
    @@do_after_save = false
    if @first_data.blank?
      update_attribute(:total_value, self.value)
    else      
      value_tmp = @first_data.total_value.nil? ? 0 : @first_data.total_value
      value_up = case action 
        when 'create' then(value + value_tmp) 
        when 'update' then(@first_data.total_value - @selected_data.value) + value
        when 'delete' then(@first_data.total_value - value) 
      end
     if action == "delete" && @first_data == @selected_data       
        @all_data[1].update_attribute(:total_value, value) unless @all_data[1].nil?
      else
#        if action == "update"
#          value_up = 0
#          @selected_data.each do |val|
#            value_up = value_up + val.value
#          end
#          value_up =@first_data.total_value + value_up
#        end
      @first_data.update_attribute(:total_value, value_up)
     end
    @@do_after_save = true
    end
  end
  
  def get_creation_date
    @created_month, @created_year = created_at.strftime("%m"), created_at.strftime("%Y")
  end
    
  def self.get_sum_all_credit_debit(options ={})
    AccountingSaleDebitCreditValue.with_dynamic_time(options[:month], options[:year]) do
       c =AccountingSaleDebitCreditValue.find(:all, :conditions => ["sale_debit_credit_id = ?", options[:debit_credit]])                
       c.sum(&:value)
    end      
  end
  
  def self.with_dynamic_time(month, year)
    with_scope :find => { :conditions => ["MONTH(created_at) = ? AND YEAR(created_at) = ? ", month, year] } do
      yield
    end
  end
  
end
