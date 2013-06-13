class AccountingSaleBalance < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10

  belongs_to :customer
  belongs_to :accounting_sale_debit_credit, :foreign_key => "sale_debit_credit_id"
  belongs_to :currency, :foreign_key => :currency_id
  belongs_to :accounting_account, :foreign_key => :account_id
  belongs_to :contra_account, :class_name => "AccountingAccount", :foreign_key => :contra_account_id
  belongs_to :status
  belongs_to :accounting_terms_of_payment, :foreign_key => 'terms_of_payment_id'
  belongs_to :accounting_sale_signature, :foreign_key => :signature_id

  has_many :values, :class_name => "AccountingSaleDebitCreditValue", :foreign_key => "sale_balance_id", :dependent => :destroy
  has_many :credits, :class_name => "AccountingSaleDebitCreditValue", :foreign_key => "sale_balance_id", :conditions => "sale_debit_credit_id = 2"
  has_many :debits, :class_name => "AccountingSaleDebitCreditValue", :foreign_key => "sale_balance_id", :conditions => "sale_debit_credit_id = 1"
  has_many :receivables, :class_name => "Receivable", :foreign_key => "transaction_id", :dependent => :destroy
  has_many :accounting_sale_balance_details, :foreign_key => 'sale_balance_id', :dependent => :destroy
  has_many :service_details, :class_name => "AccountingSaleBalanceServiceDetail", :foreign_key => 'sale_balance_id', :dependent => :destroy
  has_many :accounting_manual_journals, :foreign_key => 'sale_id', :dependent => :destroy

  has_one :accounting_mutation, :foreign_key => 'transaction_id' ,:dependent => :destroy

  validates_presence_of :invoice_date #, :invoice_number,:po_num

  

  def create_journal
    require 'ap'
    ap self.payment_value 
    is_rupiah = currency.name.downcase == "rupiah"
    cash_value = is_rupiah ? self.payment_value : self.payment_value * self.kurs
    shipping_cost = is_rupiah ? self.shipping_cost : self.shipping_cost * self.kurs
    #    receivable_value = is_rupiah ? self.transaction_value - ( self.payment_value - self.ppn_value): (self.transaction_value- ( self.payment_value - self.ppn_value) ) * self.kurs
    #    receivable_value = is_rupiah ? self.transaction_value - self.payment_value : (self.transaction_value - self.payment_value) * self.kurs
    subtotal_value = is_rupiah ? self.transaction_value - ( self.payment_value - self.ppn_value): (self.transaction_value- ( self.payment_value - self.ppn_value) ) * self.kurs
    self.amount_account_payable = self.transaction_value - self.payment_value
#    discount_value = is_rupiah ? self.discount : self.discount * self.kurs
    #    subtotal_value = is_rupiah ? self.subtotal : self.subtotal * self.kurs
    ppn_value = is_rupiah ? self.ppn_value : self.ppn_value * self.kurs
#    shipping_cost = is_rupiah ? self.shipping_cost : self.shipping_cost * self.kurs

    #----------------- DEBIT -------------------
    values << create_sale_debit_credit_value('cash', cash_value) if cash_value!=0
    #----------------- SHIPPING COST ------------
    if shipping_cost!=0
      values << create_sale_debit_credit_value('shipping', shipping_cost)
      values << create_sale_debit_credit_value('shipping_contra', shipping_cost)
    end
    #    values << create_sale_debit_credit_value('receivable', receivable_value) if receivable_value!=0
#    values << create_sale_debit_credit_value('discount', discount_value) if discount_value!=0
    #----------------- CREDIT -------------------
#    values << create_sale_debit_credit_value('sale', subtotal_value) if subtotal_value!=0
    values << create_sale_debit_credit_value('sale', cash_value - ppn_value) if subtotal_value!=0
    values << create_sale_debit_credit_value('ppn_keluaran', ppn_value) if ppn_value!=0

#    #----------------- SHIPPING COST ------------
#    if shipping_cost!=0
#      values << create_sale_debit_credit_value('shipping', shipping_cost)
#      values << create_sale_debit_credit_value('shipping_contra', shipping_cost)
#    end
  end

  def create_manual_journal
    is_rupiah = currency.name.downcase == "rupiah"
    discount_value = is_rupiah ? self.discount : self.discount * self.kurs
    receivable_value = is_rupiah ? self.transaction_value - ( self.payment_value - self.ppn_value): (self.transaction_value- ( self.payment_value - self.ppn_value) ) * self.kurs
    if receivable_value!=0
      mj = AccountingManualJournal.new(:evidence => self.invoice_number,:description => self.customer.name,:editable => false )
      mj.values.build(:account_id => AccountingSaleDebitCredit.find_by_account_type('receivable').account_id,:is_debit => true ,:value => receivable_value - discount_value )
      mj.values.build(:account_id => AccountingSaleDebitCredit.find_by_account_type('discount').account_id,:is_debit => true ,:value => discount_value ) if discount_value != 0
      mj.values.build(:account_id => AccountingSaleDebitCredit.find_by_account_type('sale').account_id,:is_debit => false ,:value => receivable_value )
      accounting_manual_journals << mj
    end
  end

  def delete_values
    accounting_manual_journals.each do |value|
      value.destroy
    end
    values.each do |value|
      value.destroy
    end
  end

  def create_sale_debit_credit_value(sale_debit_credit_account_type, value)
    sale_debit_credit = AccountingSaleDebitCredit.find_by_account_type(sale_debit_credit_account_type)
    sale_debit_credit_value = AccountingSaleDebitCreditValue.new(
      :sale_debit_credit_id => sale_debit_credit.id,
      :account_id => AccountingSaleDebitCredit.find_by_account_type(sale_debit_credit_account_type).account_id,
      :is_debit => sale_debit_credit.debit,
      :value => value,
      :total_value => value,
      :created_at => self.invoice_date
    )
    return sale_debit_credit_value
  end
  
  def sum_total_discount(action) 
    get_creation_date
    AccountingSaleBalance.with_dynamic_time(@created_month, @created_year) do
      @first_data_discount = AccountingSaleBalance.find(:first)            
      @all_data_discount = AccountingSaleBalance.find(:all, :conditions => ["id is not null"])                
    end
    @selected_data_discount = AccountingSaleBalance.find(:first, :conditions => ["id = ?", id])
    month_selected = @selected_data_discount.invoice_date.strftime("%m")
    year_selected = @selected_data_discount.invoice_date.strftime("%Y")           
    day_selected = @selected_data_discount.invoice_date.strftime("%d")      
    @all_data_before = AccountingSaleBalance.find(:all, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                            
    @first_data_before = AccountingSaleBalance.find(:first, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                                      
    @@do_after_save = false
    if @first_data_discount.nil?       
      if action == "update" && @created_month !=month_selected  #&& @first_data_discount == @selected_data_discount                
        # p @first_data_before
        # kalo data yang dipindahin adalah first row dari bulan tersebut
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
          (@first_data_discount.total_discount + discount)
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
    AccountingSaleBalance.with_dynamic_time(@created_month, @created_year) do
      @first_data_sub = AccountingSaleBalance.find(:first)            
      @all_data_sub = AccountingSaleBalance.find(:all, :conditions => ["id is not null"])                
    end
    @selected_data_sub = AccountingSaleBalance.find(:first, :conditions => ["id = ?", id])
    month_selected = @selected_data_sub.invoice_date.strftime("%m")
    year_selected = @selected_data_sub.invoice_date.strftime("%Y")           
    day_selected = @selected_data_sub.invoice_date.strftime("%d")      
    @all_data_before = AccountingSaleBalance.find(:all, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                            
    @first_data_before = AccountingSaleBalance.find(:first, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                                      
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
  
  
  def sum_total_sales(action) 
    get_creation_date       
    AccountingSaleBalance.with_dynamic_time(@created_month, @created_year) do
      @first_data_sales = AccountingSaleBalance.find(:first)            
      @all_data_sales = AccountingSaleBalance.find(:all, :conditions => ["id is not null"])                
    end
    @selected_data_sales = AccountingSaleBalance.find(:first, :conditions => ["id = ?", id])
    month_selected = @selected_data_sales.invoice_date.strftime("%m")
    year_selected = @selected_data_sales.invoice_date.strftime("%Y")           
    day_selected = @selected_data_sales.invoice_date.strftime("%d")      
    @all_data_before = AccountingSaleBalance.find(:all, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                            
    @first_data_before = AccountingSaleBalance.find(:first, :conditions => ["month(invoice_date)=? and year(invoice_date)=?",month_selected,year_selected])                                      
    @@do_after_save = false
    if @first_data_sales.nil?       
      if action == "update" && @created_month !=month_selected  #&& @first_data_sub == @selected_data_sub                
        # p @first_data_before
        # kalo data yang dipindahin adalah first row dari bulan tersebut
        if @first_data_before == @selected_data_sales             
          @all_data_before[1].update_attribute(:final_total_sale, @first_data_before.final_total_sale - @selected_data_sales.transaction_value) unless  @all_data_before[1].nil?               
          @selected_data_sales.update_attribute(:final_total_sale, transaction_value)              
        else          
          @first_data_before.update_attribute(:final_total_sale, @first_data_before.final_total_sale - @selected_data_sales.transaction_value)          
          @selected_data_sales.update_attribute(:final_total_sale, transaction_value)              
        end  
      else
        update_attribute(:final_total_sale, transaction_value)              
      end       
    else  
      day_first = @first_data_sales.invoice_date.strftime("%d")        
      value_sale = @first_data_sales.final_total_sale.blank? ? 0 : @first_data_sales.final_total_sale               
      $value_sale = case action            
      when 'create' then (transaction_value + value_sale )   
      when 'update' then
        if (month_selected == @created_month) && (year_selected == @created_year)
          (@first_data_sales.final_total_sale - @selected_data_sales.transaction_value) + transaction_value
        else                    
          (@first_data_sales.final_total_sale + transaction_value)
        end
      when 'delete' then (@first_data_sales.final_total_sale - @selected_data_sales.transaction_value)
      end      
      if action == "delete" && @first_data_sales == @selected_data_sales
        @all_data_sales[1].update_attribute(:final_total_sale, $value_sale) unless @all_data_sales[1].nil?
      end
                  
      if (action == "update" && month_selected != @created_month) || (action == "update" && year_selected != @created_year) 
        if @first_data_before == @selected_data_sales                       
          @all_data_before[1].update_attribute(:final_total_sale, @first_data_before.final_total_sale - @selected_data_sales.transaction_value) unless  @all_data_before[1].nil?  
          #jika lebih awal dari first_row
        else          
          @first_data_before.update_attribute(:final_total_sale, @first_data_before.final_total_sale - @selected_data_sales.transaction_value)
          #jika lebih awal dari first_row
        end       
      end    
      if day_selected <= day_first  
        @selected_data_sales.update_attribute(:final_total_sale, $value_sale)
      end
      
      @first_data_sales.update_attribute(:final_total_sale , $value_sale)                                               
    end    
    @@do_after_save = true
  end

  # {Total Transaksi per bulan}
  def self.get_sum_all(options ={})
    AccountingSaleBalance.with_dynamic_time(options[:month], options[:year]) do
      AccountingSaleBalance.find(:first, :conditions => ["id is not null"])
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

end
