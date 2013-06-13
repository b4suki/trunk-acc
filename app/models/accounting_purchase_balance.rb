class AccountingPurchaseBalance < ActiveRecord::Base  
  belongs_to :vendor, :foreign_key => :vendor_id
  belongs_to :currency, :foreign_key => :currency_id
  belongs_to :accounting_account, :foreign_key => :account_id
  belongs_to :contra_account, :class_name => "AccountingAccount", :foreign_key => :contra_account_id
  belongs_to :accounting_purchase_debit_credit, :foreign_key => :purchase_debit_credit_id
  belongs_to :item
  belongs_to :status
  belongs_to :accounting_terms_of_payment, :foreign_key => 'terms_of_payment_id'

  has_many :values, :class_name => "AccountingPurchaseDebitCreditValue", :foreign_key => "purchase_balance_id", :dependent => :destroy
  has_many :accounting_purchase_balance_details , :foreign_key => 'purchase_balance_id', :dependent => :destroy
  has_many :liabilities, :class_name => "Liability", :foreign_key => "transaction_id", :dependent => :destroy
  has_many :item_details, :foreign_key => "purchase_balance_id"

  has_one :fixed_asset,:class_name => "AccountingFixedAsset", :foreign_key => "purchase_balance_id", :dependent => :destroy
  has_one :accounting_mutation, :foreign_key => 'transaction_id' ,:dependent => :destroy

  validates_presence_of :invoice_date
  cattr_reader :per_page
  @@per_page = 10


  def after_create
    #    sum_total_discount('create')
    #    sum_total_subtotal('create')
    #    sum_total_purchase('create')
  end
  
  def before_update       
    #    if @@do_after_save
    #      sum_total_discount('update')
    #      sum_total_subtotal('update')
    #      sum_total_purchase('update')
    #    end
  end
  
  def before_destroy    
    #    if @@do_after_save
    #      sum_total_discount('delete')
    #      sum_total_subtotal('delete')
    #      sum_total_purchase('delete')
    #    end
  end

  def create_journal
    is_rupiah = currency.name.downcase == "rupiah"
    self.total_discount = self.discount
    subtotal_value = is_rupiah ? self.subtotal.to_f : self.subtotal.to_f * self.kurs.to_f
    ppn_value = is_rupiah ? self.ppn_value : self.ppn_value * self.kurs.to_f
    cash_value = is_rupiah ? self.payment_value : self.payment_value * self.kurs.to_f
    discount_value = is_rupiah ? self.discount : self.discount * self.kurs.to_f
    payable_value = is_rupiah ? self.transaction_value - self.payment_value : (self.transaction_value - self.payment_value) * self.kurs.to_f
    shipping_cost = is_rupiah ? self.shipping_cost : self.shipping_cost * self.kurs.to_f

    #---------------- DEBIT ------------------
    values << fill_purchase_debit_credit_value('purchase', subtotal_value) if subtotal_value!=0
    values << fill_purchase_debit_credit_value('ppn_masukan', ppn_value) if ppn_value!=0

    #---------------- CREDIT -----------------
    values << fill_purchase_debit_credit_value('cash', cash_value) if cash_value!=0
    values << fill_purchase_debit_credit_value('discount', discount_value) if discount_value!=0
    values << fill_purchase_debit_credit_value('payable', payable_value) if payable_value!=0

    self.amount_account_receivable = self.transaction_value - self.payment_value

    #---------------- SHIPPING -----------------
    if shipping_cost!=0
      values << fill_purchase_debit_credit_value('shipping_debit', shipping_cost)
      values << fill_purchase_debit_credit_value('shipping_credit', shipping_cost)
    end
  end

  def delete_values
    values.each do |value|
      value.destroy
    end
  end

  def fill_purchase_debit_credit_value(purchase_debit_credit_account_type , value)
    purchase_debit_credit = AccountingPurchaseDebitCredit.find_by_account_type(purchase_debit_credit_account_type)
    values = AccountingPurchaseDebitCreditValue.new(
      :purchase_debit_credit_id => purchase_debit_credit.id,
      :account_id => AccountingPurchaseDebitCredit.find_by_account_type(purchase_debit_credit_account_type).account_id,
      :is_debit => purchase_debit_credit.debit,
      :value => value,
      :total_value => value,
      :group_id => self.invoice_number,
      :created_at => self.invoice_date)
    return values
  end
  
  def sum_total_discount(action)
    get_creation_date       
    AccountingPurchaseBalance.with_dynamic_time(@created_month, @created_year) do
      @first_data_discount = AccountingPurchaseBalance.find(:first)            
      @all_data_discount = AccountingPurchaseBalance.find(:all, :conditions => ["id is not null"])                
    end
    @selected_data_discount = AccountingPurchaseBalance.find(:first, :conditions => ["id = ?", id])
    month_selected = @selected_data_discount.invoice_date.strftime("%m")
    year_selected = @selected_data_discount.invoice_date.strftime("%Y")           
    day_selected = @selected_data_discount.invoice_date.strftime("%d")      
    @all_data_before = AccountingPurchaseBalance.find(:all, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                            
    @first_data_before = AccountingPurchaseBalance.find(:first, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                                      
    @@do_after_save = false
    if @first_data_discount.nil?       
      if action == "update" && @created_month !=month_selected  #&& @first_data_discount == @selected_data_discount
        if @first_data_before == @selected_data_discount             
          @all_data_before[1].update_attribute(:total_discount, @first_data_before.total_discount - @selected_data_discount.discount) unless  @all_data_before[1].nil?               
          @selected_data_discount.update_attribute(:total_discount, discount)              
        else          
          @first_data_before.update_attribute(:total_discount, @first_data_before.total_discount - @selected_data_discount.discount)          
          @selected_data_discount.update_attribute(:total_discount, discount)              
        end  
      else
        update_attribute(:total_discount, discount)              
      end       
    else  
      day_first = @first_data_discount.invoice_date.strftime("%d")        
      value_discount = @first_data_discount.total_discount.blank? ? 0 :@first_data_discount.total_discount               
      $value_disc = case action            
      when 'create' then (discount + value_discount )   
      when 'update' then
        if (month_selected == @created_month) && (year_selected == @created_year)
          (@first_data_discount.total_discount - @selected_data_discount.discount) + discount
        else                    
          (@first_data_discount.total_discount +   discount)
        end
      when 'delete' then (@first_data_discount.total_discount - @selected_data_discount.discount)
      end      
      if action == "delete" && @first_data_discount == @selected_data_discount
        @all_data_discount[1].update_attribute(:total_discount, $value_disc) unless @all_data_discount[1].nil?
      end
                  
      if (action == "update" && month_selected != @created_month) || (action == "update" && year_selected != @created_year) 
        if @first_data_before == @selected_data_discount                       
          @all_data_before[1].update_attribute(:total_discount, @first_data_before.total_discount - @selected_data_discount.discount) unless  @all_data_before[1].nil?  
          #jika lebih awal dari first_row
        else          
          @first_data_before.update_attribute(:total_discount, @first_data_before.total_discount - @selected_data_discount.discount)
          #jika lebih awal dari first_row
        end       
      end    
      if day_selected <= day_first  
        @selected_data_discount.update_attribute(:total_discount, $value_disc)
      end
      
      @first_data_discount.update_attribute(:total_discount , $value_disc)                                               
    end    
    @@do_after_save = true
  end
   
   
  def sum_total_subtotal(action)
    get_creation_date       
    AccountingPurchaseBalance.with_dynamic_time(@created_month, @created_year) do
      @first_data_sub = AccountingPurchaseBalance.find(:first)            
      @all_data_sub = AccountingPurchaseBalance.find(:all, :conditions => ["id is not null"])                
    end
    @selected_data_sub = AccountingPurchaseBalance.find(:first, :conditions => ["id = ?", id])
    month_selected = @selected_data_sub.invoice_date.strftime("%m")
    year_selected = @selected_data_sub.invoice_date.strftime("%Y")           
    day_selected = @selected_data_sub.invoice_date.strftime("%d")      
    @all_data_before = AccountingPurchaseBalance.find(:all, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                            
    @first_data_before = AccountingPurchaseBalance.find(:first, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                                      
    @@do_after_save = false
    if @first_data_sub.nil?       
      if action == "update" && @created_month !=month_selected  #&& @first_data_sub == @selected_data_sub                
        # p @first_data_before
        # kalo data yang dipindahin adalah first row dari bulan tersebut
        if @first_data_before == @selected_data_sub             
          @all_data_before[1].update_attribute(:total_subtotal, @first_data_before.total_subtotal - @selected_data_sub.subtotal) unless  @all_data_before[1].nil?               
          @selected_data_sub.update_attribute(:total_subtotal, subtotal)              
        else          
          @first_data_before.update_attribute(:total_subtotal, @first_data_before.total_subtotal - @selected_data_sub.subtotal)          
          @selected_data_sub.update_attribute(:total_subtotal, subtotal)              
        end  
      else
        update_attribute(:total_subtotal, subtotal)              
      end       
    else  
      day_first = @first_data_sub.invoice_date.strftime("%d")        
      value_subtotal = @first_data_sub.total_subtotal.blank? ? 0 : @first_data_sub.total_subtotal               
      $value_sub = case action            
      when 'create' then (subtotal + value_subtotal )   
      when 'update' then
        if (month_selected == @created_month) && (year_selected == @created_year)
          (@first_data_sub.total_subtotal - @selected_data_sub.subtotal) + subtotal
        else                    
          (@first_data_sub.total_subtotal + subtotal)
        end
      when 'delete' then (@first_data_sub.total_subtotal - @selected_data_sub.subtotal)
      end      
      if action == "delete" && @first_data_sub == @selected_data_sub
        @all_data_sub[1].update_attribute(:total_subtotal, $value_disc) unless @all_data_sub[1].nil?
      end
                  
      if (action == "update" && month_selected != @created_month) || (action == "update" && year_selected != @created_year) 
        if @first_data_before == @selected_data_sub                       
          @all_data_before[1].update_attribute(:total_subtotal, @first_data_before.total_subtotal - @selected_data_sub.subtotal) unless  @all_data_before[1].nil?  
          #jika lebih awal dari first_row
        else          
          @first_data_before.update_attribute(:total_subtotal, @first_data_before.total_subtotal - @selected_data_sub.subtotal)
          #jika lebih awal dari first_row
        end       
      end    
      if day_selected <= day_first  
        @selected_data_sub.update_attribute(:total_subtotal, $value_sub)
      end
      
      @first_data_sub.update_attribute(:total_subtotal , $value_sub)                                               
    end    
    @@do_after_save = true
  end
  
  def sum_total_purchase(action)
    get_creation_date       
    AccountingPurchaseBalance.with_dynamic_time(@created_month, @created_year) do
      @first_data_purchase = AccountingPurchaseBalance.find(:first)            
      @all_data_purchase = AccountingPurchaseBalance.find(:all, :conditions => ["id is not null"])                
    end
    @selected_data_purchase = AccountingPurchaseBalance.find(:first, :conditions => ["id = ?", id])
    month_selected = @selected_data_purchase.invoice_date.strftime("%m")
    year_selected = @selected_data_purchase.invoice_date.strftime("%Y")           
    day_selected = @selected_data_purchase.invoice_date.strftime("%d")      
    @all_data_before = AccountingPurchaseBalance.find(:all, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                            
    @first_data_before = AccountingPurchaseBalance.find(:first, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                                      
    @@do_after_save = false
    if @first_data_purchase.nil?       
      if action == "update" && @created_month !=month_selected  #&& @first_data_sub == @selected_data_sub                
        # p @first_data_before
        # kalo data yang dipindahin adalah first row dari bulan tersebut
        if @first_data_before == @selected_data_purchase                 
          @all_data_before[1].update_attribute(:final_total_purchase, @first_data_before.final_total_purchase - @selected_data_purchase.transaction_value) unless  @all_data_before[1].nil?               
          @selected_data_purchase.update_attribute(:final_total_purchase, transaction_value)              
        else                    
          @first_data_before.update_attribute(:final_total_purchase, @first_data_before.final_total_purchase - @selected_data_purchase.transaction_value)          
          @selected_data_purchase.update_attribute(:final_total_purchase, transaction_value)              
        end  
      else
        update_attribute(:final_total_purchase, transaction_value)              
      end       
    else  
      day_first = @first_data_purchase.invoice_date.strftime("%d")        
      value_sale = @first_data_purchase.final_total_purchase.blank? ? 0 : @first_data_purchase.final_total_purchase               
      $value_purchase = case action            
      when 'create' then (transaction_value + value_sale )   
      when 'update' then
        if (month_selected == @created_month) && (year_selected == @created_year)
          (@first_data_purchase.final_total_purchase - @selected_data_purchase.transaction_value) + transaction_value
        else                    
          (@first_data_purchase.final_total_purchase + @selected_data_purchase.transaction_value)
        end
      when 'delete' then (@first_data_purchase.final_total_purchase - @selected_data_purchase.transaction_value)
      end      
      if action == "delete" && @first_data_purchase == @selected_data_purchase
        @all_data_purchase[1].update_attribute(:final_total_purchase, $value_purchase) unless @all_data_purchase[1].nil?
      end
                  
      if (action == "update" && month_selected != @created_month) || (action == "update" && year_selected != @created_year) 
        if @first_data_before == @selected_data_purchase                       
          @all_data_before[1].update_attribute(:final_total_purchase, @first_data_before.final_total_purchase - @selected_data_purchase.transaction_value) unless  @all_data_before[1].nil?  
          #jika lebih awal dari first_row
        else          
          @first_data_before.update_attribute(:final_total_purchase, @first_data_before.final_total_purchase - @selected_data_purchase.transaction_value)
          #jika lebih awal dari first_row
        end       
      end    
      if day_selected <= day_first  
        @selected_data_purchase.update_attribute(:final_total_purchase, $value_purchase)
      end
      
      @first_data_purchase.update_attribute(:final_total_purchase , $value_purchase)                                               
    end    
    @@do_after_save = true
  end

  # {Total Transaksi per bulan}
  def self.get_sum_all_purchase(options ={})
    AccountingPurchaseBalance.with_dynamic_time(options[:month], options[:year]) do
      AccountingPurchaseBalance.find(:first)  
    end    
  end
  
  # Kondisi default yang ditempelkan pada query apapun
  def self.with_dynamic_time(month, year)
    with_scope :find => { :conditions => ["MONTH(invoice_date) = ? AND YEAR(invoice_date) = ?", month, year] } do
      yield
    end
  end
  
  def get_creation_date        
    @created_month, @created_year = invoice_date.strftime("%m"), invoice_date.strftime("%Y")
  end
  
  def self.with_current_time
    current_month = Time.now.strftime("%m")
    current_year = Time.now.strftime("%Y")
    with_scope :find => { :conditions => ["MONTH(invoice_date) = ? AND YEAR(invoice_date) = ?", current_month, current_year] } do
      yield
    end
  end
  
  def self.find_with_current_time(*args)
    with_current_time {find(*args)}
  end
  
  def self.find_adjustment()    
    @adjust =AccountingPurchaseBalance.find(:all ,:joins => "INNER JOIN adjustment_accounts on accounting_purchase_balances.account_id = adjustment_accounts.account_id")
  end
  
end
