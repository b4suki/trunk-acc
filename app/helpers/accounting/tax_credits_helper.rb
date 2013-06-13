module Accounting::TaxCreditsHelper
  def selected_vendor(tax_credit)
    tax_credit.vendor.name unless tax_credit.vendor_id.nil?
  end

  def selected_vendor_id(tax_credit)
    tax_credit.vendor_id unless tax_credit.vendor_id.nil?
  end
  
  def selected_customer(tax_credit)
    tax_credit.customer.name unless tax_credit.customer_id.nil?
  end

  def selected_customer_id(tax_credit)
    tax_credit.customer_id unless tax_credit.customer_id.nil?
  end
end
