module LiabilityMutationsHelper
  def get_credit_mutations(vendor_id)
    value = 0
    conditions = []
    conditions << "MONTH(invoice_date)=#{$month}"
    conditions << "YEAR(invoice_date)=#{$year}"
    conditions << "vendor_id='#{vendor_id}'"
    conditions = conditions.join(" AND ")
    purchases = AccountingPurchaseBalance.find(:all, :conditions => conditions)
    purchases.each do |purchase|
      is_rupiah = purchase.currency.name.downcase == "rupiah"
      value += is_rupiah ? purchase.transaction_value - purchase.payment_value : (purchase.transaction_value - purchase.payment_value) * purchase.kurs.to_f
    end
    value
  end

  def get_debit_mutations(vendor_id)
    conditions = []
    conditions << "MONTH(updated_at)=#{$month}"
    conditions << "YEAR(updated_at)=#{$year}"
    conditions << "vendor_customer_id='#{vendor_id}'"
    conditions = conditions.join(" AND ")
    liabilities = Liability.find(:all, :conditions => conditions)
    value = 0
    liabilities.each do |liability|
      is_rupiah = liability.purchase.currency.name.downcase == "rupiah"
      value += is_rupiah ? liability.payed_value : liability.payed_value * liability.purchase.kurs.to_f
    end
    value
  end

  def get_last_value(vendor_id,month)
    before = false
    if $month == "1"
      $month = "13"
      $year = ($year.to_i - 1).to_s
      before = true
    end
    payable_value = 0
    conditions = "(MONTH(invoice_date) BETWEEN 1 AND #{month.to_i - 1}) AND YEAR(invoice_date)=#{$year} AND vendor_id='#{vendor_id}'"
    purchases = AccountingPurchaseBalance.find(:all, :conditions => conditions)
    purchases.each do |purchase|
      is_rupiah = purchase.currency.name.downcase == "rupiah"
      payable_value += is_rupiah ? purchase.amount_account_receivable : purchase.amount_account_receivable * purchase.kurs.to_f
    end
    $month = "1" if before
    $year = ($year.to_i + 1).to_s if before
    payable_value
  end
end
