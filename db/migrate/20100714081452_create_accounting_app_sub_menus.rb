class CreateAccountingAppSubMenus < ActiveRecord::Migration
  def self.up
    create_table :accounting_app_sub_menus do |t|
      t.string "title"
      t.string "url"
      t.integer "sequence"
      t.integer "menu_id"
      t.timestamps
    end

    AccountingAppSubMenu.create(:id => 1, :title => "Manage User", :url => "/admin/users", :sequence => 1, :menu_id => 1)
    AccountingAppSubMenu.create(:id => 2, :title => "Manage Roles", :url => "/admin/manage_roles", :sequence => 2, :menu_id => 1)
    
    AccountingAppSubMenu.create(:id => 3, :title => "Profil", :url => "/", :sequence => 3, :menu_id => 2)
    AccountingAppSubMenu.create(:id => 4, :title => "Pesan", :url => "/users/inbox", :sequence => 4, :menu_id => 2)
    AccountingAppSubMenu.create(:id => 5, :title => "Chat", :url => "/", :sequence => 5, :menu_id => 2)

    AccountingAppSubMenu.create(:id => 6, :title => "Items", :url => "/items", :sequence => 6, :menu_id => 3)
    AccountingAppSubMenu.create(:id => 7, :title => "Layanan", :url => "/services", :sequence => 7, :menu_id => 3)
    AccountingAppSubMenu.create(:id => 8, :title => "Kode Rekening", :url => "/accounting/accounts", :sequence => 8, :menu_id => 3)
    AccountingAppSubMenu.create(:id => 9, :title => "Vendors", :url => "/vendors", :sequence => 9, :menu_id => 3)
    AccountingAppSubMenu.create(:id => 10, :title => "Customers", :url => "/customers", :sequence => 10, :menu_id => 3)
    AccountingAppSubMenu.create(:id => 11, :title => "Account Pajak", :url => "/accounting/taxes", :sequence => 11, :menu_id => 3)

    AccountingAppSubMenu.create(:id => 12, :title => "Transaksi Kas", :url => "/accounting/cash_balances", :sequence => 12, :menu_id => 4)
    AccountingAppSubMenu.create(:id => 13, :title => "Transaksi Bank", :url => "/accounting/bank_balances", :sequence => 13, :menu_id => 4)
    AccountingAppSubMenu.create(:id => 14, :title => "Transaksi Kas Dollar", :url => "/accounting/dollar_balances", :sequence => 14, :menu_id => 4)
    AccountingAppSubMenu.create(:id => 15, :title => "Transaksi Penjualan", :url => "/accounting/sale_balances", :sequence => 15, :menu_id => 4)
    AccountingAppSubMenu.create(:id => 16, :title => "Transaksi Pembelian", :url => "/accounting/purchase_balances", :sequence => 16, :menu_id => 4)
    AccountingAppSubMenu.create(:id => 17, :title => "Manual Journal", :url => "/accounting/manual_journals", :sequence => 17, :menu_id => 4)
    AccountingAppSubMenu.create(:id => 18, :title => "Kredit Pajak", :url => "/accounting/tax_credits", :sequence => 18, :menu_id => 4)

    AccountingAppSubMenu.create(:id => 19, :title => "Jatuh Tempo Utang", :url => "/accounting/liability_maturities", :sequence => 19, :menu_id => 5)
    AccountingAppSubMenu.create(:id => 20, :title => "Jatuh Tempo Piutang", :url => "/accounting/receivable_maturities", :sequence => 20, :menu_id => 5)

    AccountingAppSubMenu.create(:id => 21, :title => "Mutasi Utang", :url => "/accounting/liability_mutations", :sequence => 21, :menu_id => 6)
    AccountingAppSubMenu.create(:id => 22, :title => "Mutasi Piutang", :url => "/accounting/receivable_mutations", :sequence => 22, :menu_id => 6)

    AccountingAppSubMenu.create(:id => 23, :title => "General Journal", :url => "/accounting/general_journals", :sequence => 23, :menu_id => 7)
    AccountingAppSubMenu.create(:id => 24, :title => "Trial Balance", :url => "/accounting/trial_balances", :sequence => 24, :menu_id => 7)
    AccountingAppSubMenu.create(:id => 25, :title => "Aktiva Tetap", :url => "/accounting/adjustment_entries", :sequence => 25, :menu_id => 7)
    AccountingAppSubMenu.create(:id => 26, :title => "Adjustment Entry", :url => "/accounting/adjustments", :sequence => 26, :menu_id => 7)
    AccountingAppSubMenu.create(:id => 27, :title => "Work Sheet", :url => "/accounting/worksheets", :sequence => 27, :menu_id => 7)
    AccountingAppSubMenu.create(:id => 28, :title => "Income Statement", :url => "/accounting/income_statement", :sequence => 28, :menu_id => 7)
    AccountingAppSubMenu.create(:id => 29, :title => "Balance Sheet", :url => "/accounting/balance_sheet", :sequence => 29, :menu_id => 7)
    AccountingAppSubMenu.create(:id => 30, :title => "Cost Evaluation", :url => "/accounting/cost_evaluations", :sequence => 30, :menu_id => 7)
    AccountingAppSubMenu.create(:id => 31, :title => "Pajak", :url => "/accounting/tax_reports", :sequence => 31, :menu_id => 7)
    AccountingAppSubMenu.create(:id => 32, :title => "Cash Flow", :url => "/accounting/cash_flow", :sequence => 32, :menu_id => 7)

    AccountingAppSubMenu.create(:id => 33, :title => "Pulsa Customer", :url => "/pulsa_customers", :sequence => 33, :menu_id => 3)
    AccountingAppSubMenu.create(:id => 34, :title => "Laporan Periode", :url => "/accounting/cost_evaluations/show_period_accounts", :sequence => 33, :menu_id => 3)

  end

  def self.down
    drop_table :accounting_app_sub_menus
  end
end
