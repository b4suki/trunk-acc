class AccountingTax < ActiveRecord::Base
  belongs_to :account, :class_name => "AccountingAccount", :foreign_key => "account_id"
  
  before_create :set_rate_value, :add_to_accounting_sale_debit_credit, :add_to_accounting_purchase_debit_credit
  before_update :set_rate_value, :update_to_accounting_sale_debit_credit, :update_to_accounting_purchase_debit_credit
  before_destroy :destroy_from_accounting_sale_debit_credit, :destroy_from_accounting_purchase_debit_credit
  validates_presence_of :rate, :message => "Rate tidak boleh kosong"

  def set_rate_value
    self.rate_value = self.rate / 100
  end

  def add_to_accounting_sale_debit_credit
    if self.account_type == "ppn_keluaran"
      sale_debit_credit = AccountingSaleDebitCredit.new(
        :account_id => self.account_id,
        :account_type => self.account_type,
        :debit => false,
        :credit => true
      )
      sale_debit_credit.save
    end
  end

  def update_to_accounting_sale_debit_credit
    if self.account_type == "ppn_keluaran"
      sale_debit_credit = AccountingSaleDebitCredit.find_by_account_type(self.account_type)
      sale_debit_credit.update_attributes(
        :account_id => self.account_id,
        :account_type => self.account_type,
        :debit => false,
        :credit => true
      )
    end
  end

  def add_to_accounting_purchase_debit_credit
    if self.account_type == "ppn_masukan"
      purchase_debit_credit = AccountingPurchaseDebitCredit.new(
        :account_id => self.account_id,
        :account_type => self.account_type,
        :debit => true,
        :credit => false
      )
      purchase_debit_credit.save
    end
  end

  def update_to_accounting_purchase_debit_credit
    if self.account_type == "ppn_masukan"
      purchase_debit_credit = AccountingPurchaseDebitCredit.find_by_account_type(self.account_type)
      purchase_debit_credit.update_attributes(
        :account_id => self.account_id,
        :account_type => self.account_type,
        :debit => true,
        :credit => false
      )
    end
  end

  def destroy_from_accounting_sale_debit_credit
    if self.account_type == "ppn_keluaran"
      sale_debit_credit = AccountingSaleDebitCredit.find_by_account_type(self.account_type)
      sale_debit_credit.destroy
    end
  end
  
  def destroy_from_accounting_purchase_debit_credit
    if self.account_type == "ppn_masukan"
      purchase_debit_credit = AccountingPurchaseDebitCredit.find_by_account_type(self.account_type)
      purchase_debit_credit.destroy
    end
  end
  
end
