class ChangeJobIdDataType < ActiveRecord::Migration
  def self.up
    change_column(:accounting_bank_balances, :job_id, :string)
    change_column(:accounting_cash_balances, :job_id, :string)
    change_column(:accounting_purchase_balances, :job_id, :string)
    change_column(:accounting_sale_balances, :job_id, :string)
  end

  def self.down
    change_column(:accounting_bank_balances, :job_id, :integer)
    change_column(:accounting_cash_balances, :job_id, :integer)
    change_column(:accounting_purchase_balances, :job_id, :integer)
    change_column(:accounting_sale_balances, :job_id, :integer)
  end
end
