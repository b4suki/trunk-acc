# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110624031537) do

  create_table "accounting_account_classifications", :force => true do |t|
    t.string   "name"
    t.boolean  "is_debit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_accounts", :force => true do |t|
    t.integer  "code_a"
    t.integer  "code_b"
    t.integer  "code_c"
    t.integer  "code_d"
    t.integer  "code_e"
    t.integer  "code"
    t.integer  "parent_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.string   "account_type"
    t.string   "worksheet"
    t.integer  "account_classification_id"
  end

  create_table "accounting_adjustment_balances", :force => true do |t|
    t.date     "adjustment_date"
    t.string   "description"
    t.string   "job_no"
    t.string   "evidence_no"
    t.integer  "account_id"
    t.integer  "contra_account_id"
    t.float    "values"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_app_menus", :force => true do |t|
    t.string   "window_id"
    t.string   "window_name"
    t.string   "window_text"
    t.string   "node_type"
    t.string   "url"
    t.integer  "sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_app_sub_menus", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.integer  "sequence"
    t.integer  "menu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_bank_balances", :force => true do |t|
    t.text     "description"
    t.string   "evidence"
    t.integer  "contra_account_id"
    t.string   "cg_gb_no"
    t.boolean  "debit"
    t.boolean  "credit"
    t.float    "cash_balance",      :default => 0.0
    t.float    "transaction_value", :default => 0.0
    t.float    "total_debit",       :default => 0.0
    t.float    "total_credit",      :default => 0.0
    t.string   "job_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bkk"
    t.string   "bkm"
    t.datetime "maturity_date"
  end

  create_table "accounting_bank_cashes", :force => true do |t|
    t.integer  "account_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_bank_reconciliations", :force => true do |t|
    t.float    "bank_balance"
    t.integer  "bank_balance_id"
    t.integer  "reconciliation_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_cash_balances", :force => true do |t|
    t.text     "description"
    t.string   "bkk"
    t.string   "bkm"
    t.string   "job_id"
    t.integer  "transaction_type_id"
    t.float    "total_revenue",         :default => 0.0
    t.float    "total_payment",         :default => 0.0
    t.float    "cash_balance",          :default => 0.0
    t.float    "transaction_value",     :default => 0.0
    t.float    "total_payment_by_type", :default => 0.0
    t.integer  "account_id"
    t.string   "evidence"
    t.integer  "contra_account_id",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_procedure_id"
  end

  create_table "accounting_cash_flow_activities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_cash_flow_categories", :force => true do |t|
    t.string   "title"
    t.integer  "activity_id"
    t.boolean  "is_cash_receipt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_cash_flow_debit_credits", :force => true do |t|
    t.integer  "category_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_cashes", :force => true do |t|
    t.integer  "account_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_dollar_balances", :force => true do |t|
    t.date     "transaction_date"
    t.string   "transaction_evidence"
    t.float    "dollar_balance"
    t.float    "kurs"
    t.float    "total_revenue"
    t.float    "total_payment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "accounting_evidence_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_fixed_asset_details", :force => true do |t|
    t.date    "transaction_date"
    t.float   "asset_values"
    t.float   "depreciation_values"
    t.float   "aje_values"
    t.integer "fixed_asset_id"
    t.integer "account_id"
  end

  create_table "accounting_fixed_assets", :force => true do |t|
    t.date    "date_purchase"
    t.string  "description"
    t.float   "value"
    t.float   "scrap_value"
    t.integer "valuable_age"
    t.integer "purchase_balance_id"
    t.integer "qty"
    t.integer "adjustment_account_id"
  end

  create_table "accounting_journal_values", :force => true do |t|
    t.integer  "account_id"
    t.float    "value"
    t.integer  "journal_id"
    t.boolean  "is_debit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_journals", :force => true do |t|
    t.string   "evidence"
    t.text     "description"
    t.integer  "account_id"
    t.integer  "contra_account_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "job_id"
    t.boolean  "editable",          :default => true
    t.integer  "sale_id"
  end

  create_table "accounting_mutations", :force => true do |t|
    t.string   "type"
    t.float    "payed_value"
    t.float    "last_value"
    t.integer  "transaction_id"
    t.integer  "vendor_customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "evidence"
    t.integer  "journal_id"
  end

  create_table "accounting_purchase_balance_details", :force => true do |t|
    t.integer  "purchase_balance_id"
    t.string   "product_name"
    t.float    "qty"
    t.float    "price"
    t.float    "discount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "subtotal"
    t.integer  "item_id"
    t.float    "disc_percentage"
    t.boolean  "received"
  end

  create_table "accounting_purchase_balances", :force => true do |t|
    t.string   "invoice_number"
    t.datetime "invoice_date"
    t.integer  "vendor_id"
    t.string   "description"
    t.string   "job_id"
    t.float    "subtotal",                  :default => 0.0
    t.float    "discount",                  :default => 0.0
    t.float    "transaction_value",         :default => 0.0
    t.integer  "purchase_debit_credit_id"
    t.float    "total_subtotal",            :default => 0.0
    t.float    "amount_account_receivable", :default => 0.0
    t.float    "total_discount",            :default => 0.0
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contra_account_id"
    t.string   "evidence"
    t.float    "price"
    t.float    "qty"
    t.float    "disc_percentage",           :default => 0.0
    t.string   "po_out"
    t.string   "travel_pass"
    t.datetime "maturity_date"
    t.integer  "status_id"
    t.integer  "terms_of_payment_id"
    t.integer  "group_id"
    t.datetime "shipping_date"
    t.float    "shipping_cost",             :default => 0.0
    t.integer  "currency_id"
    t.string   "kurs",                      :default => "0"
    t.integer  "item_id"
    t.boolean  "received"
    t.float    "ppn_value"
    t.float    "paid",                      :default => 0.0
    t.boolean  "taxable"
    t.float    "payment_value",             :default => 0.0
  end

  create_table "accounting_purchase_debit_credit_values", :force => true do |t|
    t.integer  "purchase_balance_id"
    t.integer  "purchase_debit_credit_id"
    t.float    "value"
    t.float    "total_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group_id"
    t.integer  "account_id"
    t.boolean  "is_debit"
  end

  create_table "accounting_purchase_debit_credits", :force => true do |t|
    t.integer  "account_id"
    t.text     "description"
    t.boolean  "debit"
    t.boolean  "credit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "account_type"
  end

  create_table "accounting_reconciliation_detail_values", :force => true do |t|
    t.integer  "bank_reconciliation_id"
    t.integer  "reconciliation_details_id"
    t.float    "value"
    t.float    "total_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_reconciliation_details", :force => true do |t|
    t.string   "name"
    t.boolean  "debit",      :default => false
    t.boolean  "credit",     :default => false
    t.boolean  "company",    :default => false
    t.boolean  "bank",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_sale_balance_details", :force => true do |t|
    t.string   "product_name"
    t.float    "qty"
    t.float    "price"
    t.float    "discount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sale_balance_id"
    t.float    "subtotal"
    t.integer  "item_id"
    t.string   "description"
    t.string   "position"
  end

  create_table "accounting_sale_balance_service_details", :force => true do |t|
    t.integer  "sale_balance_id"
    t.integer  "service_id"
    t.float    "qty"
    t.float    "price"
    t.float    "subtotal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_sale_balances", :force => true do |t|
    t.string   "invoice_number"
    t.datetime "invoice_date"
    t.string   "description"
    t.string   "job_id"
    t.text     "job_description"
    t.float    "subtotal",               :default => 0.0
    t.float    "discount",               :default => 0.0
    t.integer  "sale_debit_credit_id"
    t.float    "total_subtotal",         :default => 0.0
    t.float    "amount_account_payable", :default => 0.0
    t.float    "total_discount",         :default => 0.0
    t.integer  "account_id"
    t.integer  "customer_id"
    t.float    "transaction_value",      :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price"
    t.float    "qty"
    t.float    "disc_percentage",        :default => 0.0
    t.integer  "contra_account_id"
    t.string   "evidence"
    t.string   "po_num"
    t.string   "travel_pass"
    t.datetime "maturity_date"
    t.integer  "status_id"
    t.string   "terms_of_payment_id"
    t.datetime "shipping_date"
    t.float    "shipping_cost",          :default => 0.0
    t.integer  "currency_id"
    t.float    "kurs",                   :default => 0.0
    t.float    "ppn_value",              :default => 0.0
    t.boolean  "sent"
    t.float    "payment_value",          :default => 0.0
    t.integer  "signature_id"
    t.boolean  "taxable"
    t.float    "paid",                   :default => 0.0
    t.string   "tax_reference"
  end

  create_table "accounting_sale_debit_credit_values", :force => true do |t|
    t.integer  "sale_balance_id"
    t.integer  "sale_debit_credit_id"
    t.float    "value"
    t.float    "total_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.boolean  "is_debit"
    t.date     "transfer_date"
  end

  create_table "accounting_sale_debit_credits", :force => true do |t|
    t.integer  "account_id"
    t.text     "description"
    t.boolean  "debit"
    t.boolean  "credit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "account_type"
  end

  create_table "accounting_sale_signatures", :force => true do |t|
    t.string   "company_name"
    t.string   "signatory"
    t.string   "position"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_taxes", :force => true do |t|
    t.string   "account_type"
    t.string   "description"
    t.integer  "account_id"
    t.float    "rate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rate_value"
  end

  create_table "accounting_terms_of_payments", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "days"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_transaction_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "order"
    t.string   "group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "actions", :force => true do |t|
    t.integer  "modul_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action_name"
  end

  create_table "activity_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "action"
    t.integer  "activity_loggable_id"
    t.string   "activity_loggable_type"
    t.integer  "culprit_id"
    t.string   "culprit_type"
    t.integer  "referenced_id"
    t.string   "referenced_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adjustment_accounts", :force => true do |t|
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "debit_credit"
  end

  create_table "cars", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", :force => true do |t|
    t.string   "subject",    :default => ""
    t.datetime "created_at",                 :null => false
  end

  create_table "currencies", :force => true do |t|
    t.string "name"
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "address"
    t.string   "phone"
    t.string   "fax"
    t.string   "contact"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rek_no"
    t.string   "npwp"
  end

  create_table "detail_pulsa_customers", :force => true do |t|
    t.integer  "pulsa_customer_id"
    t.date     "date_pulsa"
    t.float    "pulsa"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_id"
  end

  create_table "exchange_rates", :force => true do |t|
    t.string   "base_currency"
    t.string   "currency"
    t.float    "rate"
    t.date     "issued_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_details", :force => true do |t|
    t.integer  "item_id"
    t.integer  "qty"
    t.float    "price"
    t.date     "purchasing_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "total",               :default => 0.0
    t.integer  "sequence"
    t.integer  "purchase_balance_id"
    t.boolean  "is_deleted"
  end

  create_table "item_histories", :force => true do |t|
    t.integer  "item_id"
    t.date     "last_date"
    t.integer  "last_stock"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "value"
  end

  create_table "items", :force => true do |t|
    t.integer  "type_id"
    t.string   "item_code"
    t.string   "name"
    t.string   "alias"
    t.float    "stock"
    t.text     "description"
    t.boolean  "active"
    t.float    "price",             :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
    t.float    "total_value",       :default => 0.0
    t.string   "inventory_method",  :default => "FIFO"
    t.boolean  "completed"
    t.integer  "code_pcs"
    t.integer  "prototype_item_id"
  end

  create_table "mail", :force => true do |t|
    t.integer  "user_id",                                          :null => false
    t.integer  "message_id",                                       :null => false
    t.integer  "conversation_id"
    t.boolean  "read",                          :default => false
    t.boolean  "trashed",                       :default => false
    t.string   "mailbox",         :limit => 25
    t.datetime "created_at",                                       :null => false
  end

  create_table "messages", :force => true do |t|
    t.text     "body"
    t.string   "subject",         :default => ""
    t.text     "headers"
    t.integer  "sender_id",                          :null => false
    t.integer  "conversation_id"
    t.boolean  "sent",            :default => false
    t.datetime "created_at",                         :null => false
  end

  create_table "messages_recipients", :id => false, :force => true do |t|
    t.integer "message_id",   :null => false
    t.integer "recipient_id", :null => false
  end

  create_table "moduls", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "controller_name"
  end

  create_table "payment_procedures", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_details", :force => true do |t|
    t.integer  "item_id"
    t.integer  "product_id"
    t.integer  "quntity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.integer  "prototype_item_id"
    t.integer  "item_id"
    t.integer  "quantity"
    t.text     "discription"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.boolean  "status"
  end

  create_table "prototype_item_details", :force => true do |t|
    t.integer  "prototype_item_id"
    t.integer  "item_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prototype_items", :force => true do |t|
    t.string   "description"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_id"
  end

  create_table "pulsa_customer_payment_dates", :force => true do |t|
    t.date     "payment_date"
    t.boolean  "payment_status"
    t.integer  "pulsa_customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pulsa_customers", :force => true do |t|
    t.date     "date_install"
    t.integer  "customer_id"
    t.integer  "item_id"
    t.string   "simcard"
    t.string   "sn"
    t.string   "nopol"
    t.integer  "car_id"
    t.float    "saldo"
    t.date     "aktif"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "last_saldo"
    t.integer  "package"
    t.float    "service"
    t.float    "installment"
  end

  create_table "pulsa_settings", :force => true do |t|
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "remainders", :force => true do |t|
    t.string   "task_name"
    t.string   "description"
    t.date     "task_date"
    t.date     "alert_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_of_years", :force => true do |t|
    t.integer  "account_id"
    t.date     "date_report"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "role_menu_assignments", :force => true do |t|
    t.integer  "role_id"
    t.integer  "menu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "role_sub_menu_assignments", :force => true do |t|
    t.integer  "role_menu_assignment_id"
    t.integer  "sub_menu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rules", :force => true do |t|
    t.integer  "role_id"
    t.integer  "action_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "modul_id"
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "set_pulsa_items", :force => true do |t|
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_credits", :force => true do |t|
    t.string   "evidence"
    t.integer  "vendor_id"
    t.float    "amount",            :default => 0.0
    t.integer  "manual_journal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "ssp_date"
    t.string   "tax_type"
    t.integer  "customer_id"
  end

  create_table "trans_item_statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trans_items", :force => true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.float    "qty"
    t.integer  "status"
    t.text     "description"
    t.integer  "generated_by"
    t.datetime "generated_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_addition",      :default => false
    t.float    "price",            :default => 0.0
    t.integer  "product_id"
    t.integer  "sequence"
    t.date     "date_buy"
    t.integer  "purchase_sale_id"
  end

  create_table "trial_balances", :force => true do |t|
    t.integer  "account_id"
    t.float    "last_saldo",       :default => 0.0
    t.datetime "transaction_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "as_adjusted",      :default => 0.0
  end

  create_table "types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  create_table "vendors", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "address"
    t.string   "phone"
    t.string   "fax"
    t.string   "contact"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rek_no"
    t.string   "npwp"
  end

end
