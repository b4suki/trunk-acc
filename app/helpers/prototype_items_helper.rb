module PrototypeItemsHelper
  def add_barang_link_item(name, index)
    link_to_function name do |page|
      page.insert_html :after, "accounting_sale_balance_detail", :partial => 'accounting/sale_balances/accounting_sale_balance_detail', :object => AccountingSaleBalanceDetail.new
    end
  end

  def add_new_link_item(name, index)
    link_to_remote name,
      :url => {:action => :add_barang, :index => index },
      :loading => "$('link_add').hide();$('link-add-read').show();$('link-add-indicator').show();",
      :complete => "$('link_add').show();$('link-add-read').hide();$('link-add-indicator').hide();" ,
      :html => { :id => 'link-add-barang-trigger', :class => 'a_add'}
  end

end
