class AccountingBankCash < ActiveRecord::Base
  belongs_to :accounting_account, :foreign_key => "account_id"
  
  before_create :save_account_bank_sale_dabit_credit
  before_destroy :destroy_account_bank_sale_dabit_credit

  def destroy_account_bank_sale_dabit_credit
    sale_debit_credits = AccountingSaleDebitCredit.find_all_account_id(self.account_id)
    sale_debit_credits.destroy if !sale_debit_credits.nil?
  end

  def save_account_bank_sale_dabit_credit
    sale_debit_credit = AccountingSaleDebitCredit.find_by_account_id(self.account_id)
    AccountingSaleDebitCredit.create(:account_id => self.account_id,:account_type => 'Bank',:debit => true,:credit => false) if sale_debit_credit.nil?
    AccountingSaleDebitCredit.create(:account_id => self.account_id,:account_type => 'shipping_bank',:debit => true,:credit => false) if sale_debit_credit.nil?
  end

  def update_account_bank_sale_dabit_credit(account_id, new_account_id)
    sale_debit_credit = AccountingSaleDebitCredit.find_by_account_id(account_id)
    sale_debit_credit.update_attributes(:account_id => new_account_id,:account_type => 'Bank',:debit => true,:credit => false) if !sale_debit_credit.nil?
    sale_debit_credit.update_attributes(:account_id => new_account_id,:account_type => 'shipping_bank',:debit => true,:credit => false) if !sale_debit_credit.nil?
  end
end
