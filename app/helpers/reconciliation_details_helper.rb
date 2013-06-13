module ReconciliationDetailsHelper
  
  def show_transaction_source(company, bank)
    if company
      "Perusahaan"
    elsif bank
      "Bank"
    end
  end
  
  def show_transaction_type(debit, credit)
    if debit
      "Bertambah"
    elsif credit
      "Berkurang"
    end
  end
  
  def selected_transaction_type(reconsiliation)
    if reconsiliation.debit
      "debit"
    elsif reconsiliation.credit
      "credit"
    end
  end
  
  def selected_transaction_source(reconsiliation)
    if reconsiliation.company
      "company"
    elsif reconsiliation.bank
      "bank"
    end
  end
end
