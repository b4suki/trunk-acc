module ProductsHelper
  def add_new_link_item(name, index)
    link_to_remote name,
      :url => {:action => :add_barang, :index => index },
      :loading => "$('link_add').hide();$('link-add-read').show();$('link-add-indicator').show();",
      :complete => "$('link_add').show();$('link-add-read').hide();$('link-add-indicator').hide();" ,
      :html => { :id => 'link-add-barang-trigger', :class => 'a_add'}
  end
end
