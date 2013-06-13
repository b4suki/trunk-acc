class AccountingFixedAsset < ActiveRecord::Base
  belongs_to :accounting_purchase_balance, :foreign_key => "purchase_balance_id"
  has_many :fixed_details, :class_name => "AccountingFixedAssetDetail", :foreign_key => "fixed_asset_id" , :dependent => :destroy
  belongs_to :adjustment_account
  belongs_to :accounting_account
  
  def after_create
    save_detail()
  end

  def after_update()   
    edit_value_continously      
  end
  
#  def before_update
#      p "adf"
#      p @@do_after_save
#    if @@do_after_save
#      #  edit_value_continously
#    end
#  end
   
  def save_detail()    
    check_purchase_date(self.date_purchase,self.value, self.scrap_value,self.valuable_age)    
    AccountingFixedAssetDetail.create(
        :transaction_date => self.date_purchase,
        :asset_values => self.value, 
        :depreciation_values => $value,
        :aje_values => self.value - $value,
        :fixed_asset_id => self.id,
        :account_id => get_account_id(self.adjustment_account_id)
    )
  end
  
  def get_account_id(accounting_id)
    value = ""
    x = AdjustmentAccount.find(:first, :conditions => ['id = ?',accounting_id])
    value = x.account_id
  end
  
  def check_purchase_date(date_value,value_in,scrap_in,valuable_age)
    $value = 0
    if date_value.strftime("%d") <= "15"     
     $value = ((1.to_f/valuable_age.to_f) * (value_in - scrap_in)) *1.to_f/12.to_f               
    end 
    $value
  end

   def check_purchase_date_empty(date_value,value_in,scrap_in,valuable_age)
     value = ((1.to_f/valuable_age.to_f) * (value_in - scrap_in)) *1.to_f/12.to_f            
  end

  #jika diedit dan terjadi perubahan ke bulan dan tahun2 berikutnya
  def edit_value_continously
      
    last_transaction = AccountingFixedAssetDetail.find(:first, :conditions => ['fixed_asset_id = ?', self.id],:order => 'transaction_date desc').transaction_date
    selected_transaction_edit = AccountingFixedAssetDetail.find(:first, :conditions => ['fixed_asset_id = ?', self.id], :order => 'transaction_date asc').transaction_date
    current_transaction = self.date_purchase
    #jika transaksi diedit tanggalnya menjadi 1 atau beberapa bulan ke depan
    interval_edit = month_interval(selected_transaction_edit, current_transaction)   
    if interval_edit > 0
        1.upto(interval_edit) do |x|
            selected_trans= selected_transaction_edit.beginning_of_month.months_since(x)
            month = selected_transaction_edit.strftime("%m")
            year = selected_transaction_edit.strftime("%Y")
         search_time(month, year,self.id).each do |data|
            data.destroy
         end   
        end
    end     

    check_purchase_date(self.date_purchase,self.value, self.scrap_value,self.valuable_age)
    $counting = 0   
    interval = month_interval(current_transaction, last_transaction)  + 1
    1.upto(interval) do |x|
      selected_transaction = current_transaction.beginning_of_month.months_since(x-1)

      month = selected_transaction.strftime("%m")
      year = selected_transaction.strftime("%Y")
#      p "selected month ="
#      p month
#      p "selected year ="
#      p year
      $asset_values = self.value
     # p self.value
      $depre_value = 0
      x = search_time(month, year,self.id)
            x.each_with_index do |data, i|                  
            data.update_attributes(:transaction_date => data.transaction_date,
            :asset_values => next_value($asset_values,$depre_value, $counting),
            :depreciation_values => next_value_depreciation($value,$counting    ),
            :aje_values => $asset_values -  $depre_value ,
            :fixed_asset_id => self.id,
            :account_id => get_account_id(self.adjustment_account_id)
            )
            $counting = $counting + 1                        
      end
     end      
  end

  def next_value(value,depreciation_value,loop)
    if loop > 0
        $asset_values = $asset_values -  depreciation_value
    else        
        $asset_values = value
    end      
      $asset_values
  end

  def next_value_depreciation(value,loop)      
    if loop > 0          
      if value == 0
       value = check_purchase_date_empty(self.date_purchase,self.value, self.scrap_value,self.valuable_age) 
      end
      $depre_value = $depre_value + value
#    elsif value == 0
#        $depre_value = check_purchase_date_empty(self.date_purchase,self.value, self.scrap_value,self.valuable_age)
    else
      $depre_value = value
    end
      $depre_value
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

  def search_time(month, year, id_fixed)
    AccountingFixedAssetDetail.find(:all,:conditions => ["MONTH(transaction_date) = ? AND YEAR(transaction_date) = ? AND fixed_asset_id = ?", month, year,id_fixed])     
  end

end
