module ReceivableMaturitiesHelper
    
  def get_receivable(transaction)    
    x = Receivable.find_all_by_transaction_id(transaction.id)    
    x[0] && x[0].payed_value != nil ? x[0].payed_value : 0      
  end
  
  def show_status(transaction)
    status = ""
    st = transaction.status
    if st
      if st.id == 2 || st.name == "Paid"
        status = st.name + " " + transaction.receivables.last.updated_at.strftime("%d/%m/%Y")
      else
        status = st.name        
      end
    end
  end
end
