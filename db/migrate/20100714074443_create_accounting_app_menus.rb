class CreateAccountingAppMenus < ActiveRecord::Migration
  def self.up
    create_table :accounting_app_menus do |t|
      t.string "window_id"
      t.string "window_name"
      t.string "window_text"
      t.string "node_type"
      t.string "url"
      t.integer "sequence"
      t.timestamps
    end
    AccountingAppMenu.create(:id => 1, :window_id => "accounting-report-win", :window_name => "Administrator", :window_text => "Administrator", :node_type => "multiple", :url => nil, :sequence => 1)
    AccountingAppMenu.create(:id => 2, :window_id => "account", :window_name => "Account", :window_text => "My Account", :node_type => "multiple", :url => nil, :sequence => 2)
    AccountingAppMenu.create(:id => 3, :window_id => "data-master", :window_name => "DataMaster", :window_text => "Data Master", :node_type => "multiple", :url => nil, :sequence => 3)
    AccountingAppMenu.create(:id => 4, :window_id => "transaksi", :window_name => "Transaksi", :window_text => "Transaksi", :node_type => "multiple", :url => nil, :sequence => 4)
    AccountingAppMenu.create(:id => 5, :window_id => "jatuh-tempo", :window_name => "JatuhTempo", :window_text => "Jatuh Tempo", :node_type => "multiple", :url => nil, :sequence => 5)
    AccountingAppMenu.create(:id => 6, :window_id => "mutasi", :window_name => "Mutasi", :window_text => "Mutasi", :node_type => "multiple", :url => nil, :sequence => 6)
    AccountingAppMenu.create(:id => 7, :window_id => "laporan", :window_name => "Laporan", :window_text => "Laporan", :node_type => "multiple", :url => nil, :sequence => 7)
    AccountingAppMenu.create(:id => 8, :window_id => "detail-remainder", :window_name => "Remainder", :window_text => "Reminder", :node_type => "single", :url => "/dashboard/show_detail_remainders", :sequence => 10)
#    AccountingAppMenu.create(:id => 9, :window_id => "detail-cash-flow", :window_name => "CashFlow", :window_text => "Cash Flow", :node_type => "single", :url => "/dashboard/show_detail_cash_flow", :sequence => 11)
  end

  def self.down
    drop_table :accounting_app_menus
  end
end
