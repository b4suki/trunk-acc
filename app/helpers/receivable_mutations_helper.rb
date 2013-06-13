module ReceivableMutationsHelper
  def get_debit_mutations_receive(customer_id)
    value = 0
    sales = AccountingSaleBalance.find(:all, :conditions => "MONTH(invoice_date)=#{$month} AND YEAR(invoice_date)=#{$year} AND customer_id='#{customer_id}'")
    sales.each do |sale|
      is_rupiah = sale.currency.name.downcase=="rupiah"
      value += is_rupiah ? sale.transaction_value - sale.payment_value : (sale.transaction_value - sale.payment_value) * sale.kurs.to_f
    end
    value
  end

  def get_credit_mutations_receive(customer_id)
    value = 0
    receivables = Receivable.find(:all, :conditions => "MONTH(updated_at)=#{$month} AND YEAR(updated_at)=#{$year} AND vendor_customer_id='#{customer_id}'")
    receivables.each do |receivable|
      is_rupiah = receivable.sale.currency.name.downcase=="rupiah" if !receivable.sale.nil?
      value += is_rupiah ? receivable.payed_value : receivable.payed_value * receivable.sale.kurs if !receivable.sale.nil?
    end
    value
  end
    
  def get_last_value_receive(customer_id,month)
    before = false
    if $month == "1"
      $month = "13"
      $year = ($year.to_i - 1).to_s
      before = true
    end
    receivable_value = 0
    conditions_sale =  "(MONTH(invoice_date) BETWEEN 1 AND #{month.to_i - 1}) AND YEAR(invoice_date)=#{$year} AND customer_id='#{customer_id}'"
    sales = AccountingSaleBalance.find(:all, :conditions => conditions_sale)
    sales.each do |sale|
      is_rupiah = sale.currency.name.downcase=="rupiah"
      receivable_value += is_rupiah ? sale.amount_account_payable : sale.amount_account_payable * sale.kurs
    end
    $month = "1" if before
    $year = ($year.to_i + 1).to_s if before
    receivable_value
  end
end
