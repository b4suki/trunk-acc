authorization do

  role :general do
    has_permission_on :liability_maturities, :to => :read
    has_permission_on :receivable_maturities, :to => :read
    has_permission_on :authorization_rules, :to => :read
    has_permission_on :authorization_usages, :to => :read
  end

  role :Adminitrator do
    has_permission_on [
      :manage_roles, :users,
      :adjustment, :customers, :dashboard, :exechanges, :items, :pots, :trans_item_statuses,
      :trans_items, :types, :units, :users, :vendors, :accounts, :adjustment_accounts,
      :adjustment_balances, :adjustment_entries, :balance_sheet, :bank_balances, :bank_reconciliation,
      :cash_balances, :cost_evaluation, :cost_evaluations, :dollar_balance, :evidence_types,
      :general_journals, :income_statement, :liability_maturities, :liability_mutations,
      :manual_journals, :purchase_balances, :purchase_debit_credits, :receivable_maturities,
      :receivable_mutations, :reconciliation_details, :reports, :sale_balances, :sale_debit_credits,
      :sale_signatures, :terms_of_payments, :transaction_types, :trial_balances, :worksheets
    ], :to => :manage
    has_permission_on :authorization_rules, :to => :read
    has_permission_on :authorization_usages, :to => :read
  end

  role 'Inventory' do
    has_permission_on :items, :to => [:read,:create,:update,:delete, :ajax_data_master]
    includes :general
  end

  role :pembelian do
    includes :general
  end

  role :kas_bank do
    includes :general
  end

  role :petty_cash do
    includes :general
  end

  role :direktur do
    includes :general
  end

end

privileges do
  privilege :manage, :includes => [ 
    :create, :read, :update, :delete, :ajax_maturities, :ajax_data_master
  ]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
  privilege :ajax_maturities, :includes => [
    :do_pay, :cancel_pay, :ajax_select_status,
    :make_parameter, :make_parameter_sales, :initial_method
  ]
  privilege :ajax_data_master, :includes =>[
    :auto_complete_for_type_name,
    :auto_complete_for_unit_name, :initial_method
  ]
end