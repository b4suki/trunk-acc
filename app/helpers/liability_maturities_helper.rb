module LiabilityMaturitiesHelper
  def get_liability(transaction)
    x = Liability.find_by_transaction_id(transaction.id)    
    x && x.payed_value != nil ? x.payed_value : 0
  end
  
  def show_status_liability(transaction)
    status = ""    
    st = transaction.status_id      
      if st.to_s == '2' #|| status == "Paid"        
        status = "Paid" #+ " " + transaction.liability.paid_date.strftime("%d/%m/%Y")
      else
        status = "Allowance"
      end    
  end
end
