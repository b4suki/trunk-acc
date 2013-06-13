class AccountingAccount < ActiveRecord::Base  
  before_save :generate_code #, :decide_worksheet
  before_update :generate_code #, :decide_worksheet
  acts_as_tree :order => :code

  validates_presence_of :code_a, :code_b,:code_c, :code_d,:code_e, :description
  validates_uniqueness_of :description
  validates_uniqueness_of :code_a, :scope => [:code_b,:code_c, :code_d,:code_e]
  validates_uniqueness_of :code_b, :scope => [:code_a,:code_c, :code_d,:code_e]
  validates_uniqueness_of :code_c, :scope => [:code_a,:code_b, :code_d,:code_e]
  validates_uniqueness_of :code_d, :scope => [:code_a,:code_b, :code_c,:code_e]
  validates_uniqueness_of :code_e, :scope => [:code_a,:code_b, :code_c,:code_d]
  validates_numericality_of :code_a, :code_b,:code_c, :code_d,:code_e

  has_many :accounting_cash_balance
  has_many :accounting_bank_balance
  has_many :accounting_sale_balances
  has_many :accounting_purchase_balances
  has_many :adjustment_accounts, :foreign_key => 'account_id'
  has_many :trial_balances, :foreign_key => :account_id
  has_many :accounting_fixed_asset_details, :foreign_key => :account_id
  has_many :accounting_fixed_assets, :foreign_key => :account_id
  has_many :accounting_adjustment_balances, :foreign_key => :account_id
  has_many :accounting_cashes, :foreign_key => "account_id", :dependent => :destroy
  has_many :taxes, :class_name => "AccountingTax", :foreign_key => "account_id", :dependent => :destroy
  has_many :purchase_debit_credit_values, :class_name => "AccountingPurchaseDebitCreditValue", :foreign_key => "account_id"
  has_many :sale_debit_credit_values, :class_name => "AccountingSaleDebitCreditValue", :foreign_key => "account_id"
  has_many :accounting_cash_flow_debit_credit, :foreign_key => :account_id

  has_one :accounting_sale_debit_credit, :foreign_key => 'account_id', :dependent => :destroy
  has_one :accounting_purchase_debit_credit, :foreign_key => 'account_id', :dependent => :destroy

  belongs_to :accounting_account_classification, :foreign_key => "account_classification_id"
  
  def generate_code
    tmp = self.code_a.to_s + self.code_b.to_s + self.code_c.to_s + self.code_d.to_s + self.code_e.to_s
    self.code = tmp.to_i
  end

  def decide_worksheet
    if self.account_classification_id >=1 && self.account_classification_id <=3
      self.worksheet = "balance_sheet"
    else
      self.worksheet = "income_statement"
    end
  end

end
