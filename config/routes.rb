ActionController::Routing::Routes.draw do |map|
 
  ## Hanlde Filter Mapping
  map.connect ':controller/filter', :action => 'filter'
  
  map.resources :adjustment_accounts
  map.resources :exchanges, :collection => {:convert => :get, :currency_exchange => :post}
  
  map.namespace :accounting do |accounting|
    accounting.resources :sale_debit_credits
    accounting.resources :purchase_debit_credits
    accounting.resources :purchase_balances,  :collection => {:filter => :post, :index => :any}
    accounting.resources :reconciliation_details
    accounting.resources :bank_reconciliations
    accounting.resources :bank_balances, :collection => {:index => :any}
    accounting.resources :evidence_types
    accounting.resources :transaction_types
    accounting.resources :cash_balances, :collection => {:index => :any, :create_new_saldo => :any}
    accounting.resources :accounts, :collection => {:export_excel => :get}
    accounting.resources :sale_balances, :collection => {:filter => :post, :index => :any, 
      :edit_after_transfer => :get, :transfer_all => :get, :save_transfer_all => :post}
    accounting.resources :general_journals, :collection => {:index => :any, :post_trial_balance => :post}
    accounting.resources :manual_journals, :collection => {:index => :any }
    accounting.resources :trial_balances, :collection => {:index => :any}
    accounting.resources :reports, :collection => {:load_chart => :any, :chart => :get}
    accounting.resources :adjustment_entries, :collection => {:index => :any}
    accounting.resources :adjustment_accounts, :collection => {:index => :any}
    accounting.resources :adjustment_balances, :collection => {:index => :any}
    accounting.resources :liability_maturities, :collection => {:index => :any}
    accounting.resources :liability_mutations, :collection => {:index => :any}
    accounting.resources :receivable_maturities, :collection => {:index => :any}
    accounting.resources :receivable_mutations, :collection => {:index => :any}
    accounting.resources :cost_evaluations, :collection => {:index => :any, :show_period_accounts => :any}
    accounting.resources :worksheets, :collection => {:index => :any}
    accounting.resources :terms_of_payments, :collection => {:index => :any}
    accounting.resources :dollar_balances, :collection => {:index => :any}
    accounting.resources :sale_signatures, :collection => {:index => :any}
    accounting.resources :adjustments, :collection => {:index => :any}
    accounting.resources :general_ledgers, :collection => {:index => :any}
    accounting.resources :taxes
    accounting.resources :tax_reports, :collection => {:index => :any}
    accounting.resources :tax_credits, :collection => {:index => :any}
    accounting.resources :cash_flow, :collection => {:index => :any}
    accounting.resources :cash_flow_debit_credits, :collection => {:index => :any}
    accounting.resources :cash_flow_categories, :collection => {:index => :any}
  end
  
  map.namespace :general do |general|
    general.resources :vendors
    general.resources :customers
  end

  map.resources :trans_item_statuses
  map.resources :pulsa_customers, :collection => {:add_pulsa => :any} ,:member => {:edit_last => :get}
  map.resources :pulsa_settings
  map.resources :items, :collection => {:index => :any, :history => :get}, :member => {:update_detail =>:put, :edit_detail => :get}
  map.resources :products, :collection => {:index => :any}
  map.resources :prototype_items
  map.resources :services, :collection => {:index => :any}
  map.resources :trans_items, :collection => {:index => :any, :destroy_item => :get}
  map.resources :types, :collection => {:index => :any}
  map.resources :units, :collection => {:index => :any}
  map.resources :vendors, :collection => {:export_excel => :get}
  map.resources :customers, :collection => {:export_excel => :get}  
  map.resources :users, :collection => {:inbox => :get, :compose_message => :get, :show_message => :get, :replay_message => :get, :delete_message => :delete}
  map.resources :accounting_cashes
  map.resources :accounting_bank_cashes
  map.resource   :session
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.dashboard '/dashboard', :controller => 'dashboard', :action => 'index'
  # map.remainders '/remainders', :controller => 'dashboard' , :action => 'show_detail_remainders'
  map.resources 'remainders', :controller => 'dashboard' , :action => 'show_detail_remainders'
  #map.load_chart '/reports/load_chart', :controller => 'reports', :action => 'load_chart'
  
  # map.index 'accounting/bank_balances/:id', :controller => 'accounting/bank_balances', :action => 'index'
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  
  map.namespace :admin do |admin|
    admin.resources :manage_roles, :collection => {:set_rule => :get, :new_modul => :get, :new_action => :get, 
      :create_action => :post, :create_modul => :post, :create_rule => :post,
      :delete_modul => :get, :delete_action => :get,
    }
    admin.resources :users
  end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "dashboard"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
