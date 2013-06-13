# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def format_currency(number)
    if !number.nil?
      toggle_value = nil
      toggle_value = (number * -1) if number < 0
      value = number_to_currency(toggle_value || number, :unit => "", :delimiter => ",", :separator => ".", :precision => 2)
      if toggle_value
        "<font color='red'>(#{value})</font>"
      else
        value
      end
    end
  end
  
  def format_date(date)
    date.strftime("%d-%b-%Y")
  end
  
  def format_digit(value)
    "%04d" % value.to_i
  end
  
  def popup_title(title, cancel_text = "Batal")
    ret = "<div id=\"RB_title\">"
    ret += "<span><h3>#{title}</h3></span>"
    ret += "<span style=\"float: right; margin: -10px 10px\">"
    ret += "#{link_to_close_redbox(cancel_text, html_options = {})}"
    ret += "</span>"
    ret += "</div>"
    ret 
  end

  def popup_title_help(title, cancel_text = "Kembali")
    ret = "<div id=\"RB_title\">"
    ret += "<span><h2>#{title}</h2></span>"
    ret += "<span style=\"float: right; margin: -10px 10px\">"
    ret += "#{link_to_close_redbox(cancel_text, html_options = {})}"
    ret += "</span>"
    ret += "</div>"
    ret
  end  
  
  def indonesian_month_names
    %w(Januari Februari Maret April Mei Juni Juli Agustus September Oktober November Desember)
  end

  
  def set_checked_rule(role, action)
    role = Role.find(role)
    if role
      rule = Rule.find(:first, :conditions => ["role_id = ? AND action_id = ?", role.id, action.id])
      return rule ? true : false
    else
      return false      
    end
  end
  
  def add_debit_link(name) 
    link_to_function name do |page|
      page.insert_html :after, "accounting_sale_debit_credit",:partial => 'accounting/sale_balances/accounting_sale_debit_credit', :object => AccountingSaleDebitCredit.new     
    end 
  end 
    
  def add_credit_link(name) 
    link_to_function name do |page|     
      page.insert_html :after, "accounting_sale_credit",:partial => 'accounting/sale_balances/accounting_sale_credit', :object => AccountingSaleDebitCredit.new               
    end 
  end 
  
  def add_debit_link_purchase(name) 
    link_to_function name do |page|
      page.insert_html :after, "accounting_purchase_debit_credit",:partial => 'accounting/purchase_balances/accounting_purchase_debit_credit', :object => AccountingPurchaseDebitCredit.new     
    end 
  end 
  
  def add_barang_link(name, index)     
    link_to_function name do |page|             
      page.insert_html :after, "accounting_sale_balance_detail", :partial => 'accounting/sale_balances/accounting_sale_balance_detail', :object => AccountingSaleBalanceDetail.new
      #page.replace_html "link_add", :partial => "add_new_link", :locals => {:index => index}
      #page << "$().inner_html = "
      #page.inner_html()     
    end
  end
  
  def add_barang_link_purchase(name, index)
    link_to_function name do |page|             
      page.insert_html :after, "accounting_purchase_balance_detail", :partial => 'accounting/purchase_balances/accounting_purchase_balance_detail', :object => AccountingPurchaseBalanceDetail.new
      #page.replace_html "link_add", :partial => "add_new_link", :locals => {:index => index}
      #page << "$().inner_html = "
      #page.inner_html()
    end
  end
  
  def add_new_link(name, index, size, ppn_rate)
    link_to_remote name,
      :url => {:action => :add_barang, :index => index ,:size => size, :ppn_rate => ppn_rate},
      :loading => "$('link_add').hide();$('link-add-read').show();$('link-add-indicator').show();",
      :complete => "$('link_add').show();$('link-add-read').hide();$('link-add-indicator').hide();" ,
      :html => { :id => 'link-add-barang-trigger', :class => 'a_add'}
  end

  def add_new_service_link(name, index, size, ppn_rate)
    link_to_remote name,
      :url => {:action => :add_service, :index => index ,:size => size, :ppn_rate => ppn_rate},
      :loading => "$('link_service_add').hide();$('link-add-service-read').show();$('link-add-service-indicator').show();",
      :complete => "$('link_service_add').show();$('link-add-service-read').hide();$('link-add-service-indicator').hide();" ,
      :html => { :id => 'link-add-service-trigger', :class => 'a_add'}
  end
  
  def add_new_link_purchase(name, index, size,index_debit, index_credit, ppn_rate)
    ret = link_to_remote name,
      {:url => {:action => :add_barang, :index => index,:size => size,
        :index_debit => index_debit, :index_credit => index_credit, :ppn_rate => ppn_rate},
      :loading => "$('link-add-indicator').show();",
      :complete => "$('link-add-indicator').hide();"},
      {:class => "a_add"}
    ret << "<span id='link-add-indicator' style='float:left;display:none;'>#{image_tag "ajax-loader.gif"}</span>"
  end
    
  def add_new_link_debit(name, index, index_parent) 
    link_to_remote name, :url => {:action => :add_debit, :index => index, :index_parent => index_parent}, 
      :loading => "$('link_add_debit').hide();$('link-add-debit-read').show();$('link-add-debit-indicator').show();",
      :complete => "$('link_add_debit').show();$('link-add-debit-read').hide();$('link-add-debit-indicator').hide();"
  end
  
  def add_new_link_credit(name, index, index_parent) 
    link_to_remote name, :url => {:action => :add_credit, :index => index, :index_parent => index_parent},
      :loading => "$('link_add_credit').hide();$('link-add-credit-read').show();$('link-add-credit-indicator').show();",
      :complete => "$('link_add_credit').show();$('link-add-credit-read').hide();$('link-add-credit-indicator').hide();"
  end
  
  def add_new_link_debit_sale(name, index) 
    link_to_remote name, :url => {:action => :add_debit, :index => index}, 
      :loading => "$('link_add_debit').hide();$('link-add-debit-read').show();$('link-add-debit-indicator').show();",
      :complete => "$('link_add_debit').show();$('link-add-debit-read').hide();$('link-add-debit-indicator').hide();"
  end
  
  def add_new_link_credit_sale(name, index) 
    link_to_remote name, :url => {:action => :add_credit, :index => index},
      :loading => "$('link_add_credit').hide();$('link-add-credit-read').show();$('link-add-credit-indicator').show();",
      :complete => "$('link_add_credit').show();$('link-add-credit-read').hide();$('link-add-credit-indicator').hide();"
  end
        
  def add_credit_link_purchase(name)     
    link_to_function name do |page|     
      page.insert_html :after, "accounting_purchase_credit",:partial => 'accounting/purchase_balances/accounting_purchase_credit', :object => AccountingPurchaseDebitCredit.new         
    end 
  end 

  def add_new_debit(name, index, size)
    link_to_remote name,
      :url => {:action => :add_debit, :index => index,:size => size},
      :html => {:class => "a_add"},
      :loading => "$('link-add-debit').hide();$('link-add-debit-read').show();$('link-add-debit-indicator').show();",
      :complete => "$('link-add-debit').show();$('link-add-debit-read').hide();$('link-add-debit-indicator').hide();"
  end

  def add_new_credit(name, index, size)
    link_to_remote name,
      :url => {:action => :add_credit, :index => index,:size => size},
      :html => {:class => "a_add"},
      :loading => "$('link-add-credit').hide();$('link-add-credit-read').show();$('link-add-credit-indicator').show();",
      :complete => "$('link-add-credit').show();$('link-add-credit-read').hide();$('link-add-credit-indicator').hide();"
  end
  
  ## Building Desktop Javascript Helper
  ##
  
  def init_desktop_js(registered_windows = [], options = {})
    user = options[:current_user] || "Anonymous"
    name = "FirstWindow"
    javascript_tag <<-_JS
      MyDesktop = new Ext.app.App({
	init :function(){
	  Ext.QuickTips.init();
	},

	getModules : function(){
	  return [
	    #{build_window_lists(registered_windows)}	
	  ];
	},

        // config for the start menu
        getStartConfig : function(){
          return {
            title: '#{user}',
            iconCls: 'user',
            toolItems: [{
              text:'Konfigurasi',
              iconCls:'settings',
	            handler : showMessage,
              scope:this
            },'-',{
              text:'Keluar',
              iconCls:'logout',
	            handler: makeSureLogOut,
              scope:this
            }]
        };
      }
    });
    var windowIndex = 0; 
    _JS
  end
  
  def create_single_node(options = {})
    options[:height] ||= 500
    options[:width] ||= 600
    
    javascript_tag <<-_JS
      MyDesktop.#{options[:window_name]} = Ext.extend(Ext.app.Module, {
        id:'#{options[:window_id]}',  
        init : function(){
          this.launcher = {
	    text: '#{options[:window_text]}',
	    iconCls:'bogus',
	    handler : this.#{options[:no_window] ? 'gotoUrl' : 'createWindow' },
	    scope: this,
	    windowId:windowIndex
	  }
        },
								 
        createWindow : function(src){
          var desktop = this.app.getDesktop();
	  var win = desktop.getWindow('#{options[:window_id]}');
	  if(!win){
	    win = desktop.createWindow({
	    /*id: 'login',*/
		title:'#{options[:window_text]}',
		width: #{options[:width]},
		height: #{options[:height]},
		html : "<div id='loader-#{options[:window_id]}'></div><iframe id='content-frame-#{options[:window_id]}' style='border:none; width:100%; height:100%;' src='#{options[:url]}' #{options[:html_options]}></iframe>",
		iconCls: 'bogus',
		shim:false,
		animCollapse:false,
		constrainHeader:true
          });
	}
	win.show();
        },

        gotoUrl : function(src){
          setTimeout("location.href='#{options[:url]}'",10);
        }
      });
    _JS
  end

  def create_multiple_node(content_group, options = {})
    options[:height] ||= 500
    options[:width] ||= 600
    
    javascript_tag <<-_JS
      MyDesktop.#{options[:window_name]} = Ext.extend(Ext.app.Module, {
        id:'#{options[:window_id]}', 
	init : function(){
	  this.launcher = {
	    text: '#{options[:window_text]}',
	    iconCls:'bogus',
	    handler: function() { return false; },
	    scope: this,
	    windowId:windowIndex,
	    menu: {
	      items:[ #{get_child(content_group)} ]
            }	
	  }
	},
        #{build_dynamic_window(content_group, options)}								  
      });
    _JS
  end
  
  def build_window_lists(windows)
    return "" if windows.empty?
    size = windows.size
    content = ""
    windows.each_with_index do |name, index| 
      content += "new MyDesktop.#{name}"
      content += "," if index + 1 < size
    end
    content
  end
  
  def get_child(content_group)
    return "" if content_group.empty?
    size = content_group.size
    content = ""
    content_group.each_with_index do |t, index| 
      content += "{ text: '" + t[:title] + "', iconCls:'bogus', handler : this."+ t[:title].gsub(' ','') +", scope: this, windowId: windowIndex }"
      content += "," if index + 1 < size
    end
    content
  end
  
  def build_dynamic_window(content_group, options)
    return "" if content_group.empty?
    size = content_group.size
    content = ""
    content_group.each_with_index do |t, index|
      t[:height] ||= 500
      t[:width] ||= 600
      content += "#{t[:title].gsub(' ','')} : function(src){"
      content += "  var desktop = this.app.getDesktop();"
      content += "  var win = desktop.getWindow('#{t[:title].gsub(' ','-').downcase}');"
      content += "  if(!win){"
      content += "    win = desktop.createWindow({"
      content += "      id: '#{t[:title].gsub(' ','-').downcase}',"
      content += "      title:'#{t[:title]}',"
      content += "      width: #{t[:width]},"
      content += "      height: #{t[:height]},"
      content += "      html : \"<div id='loader-#{t[:title].gsub(' ','-').downcase}'></div><iframe id='content-frame-#{t[:title].gsub(' ','-').downcase}' style='border:none; width:100%; height:100%;' src='#{t[:url]}' #{options[:html_options]}></iframe>\","
      content += "      iconCls: 'bogus',"
      content += "      shim:false,"
      content += "      animCollapse:false,"
      content += "      constrainHeader:true"
      content += "    });"
      content += "  }"
      content += "win.show();"
      content += "}"
      content += "," if index + 1 < size
    end
    content
  end

  def find_account_id(id_account)
    account_id=AccountingAccount.find(:all, :conditions => ["id = ?",id_account]) 
    account_id
  end
  
  def windowed_pagination_links(pagingEnum, options)
    link_to_current_page = options[:link_to_current_page]
    always_show_anchors = options[:always_show_anchors]
    padding = options[:window_size]
 
    current_page = pagingEnum.page
    html = ''
 
    #Calculate the window start and end pages 
    padding = padding < 0 ? 0 : padding
    first = pagingEnum.page_exists?(current_page  - padding) ? current_page - padding : 1
    last = pagingEnum.page_exists?(current_page + padding) ? current_page + padding : pagingEnum.last_page
 
    # Print start page if anchors are enabled
    html << yield(1) if always_show_anchors and not first == 1
 
    # Print window pages
    first.upto(last) do |page|
      (current_page == page && !link_to_current_page) ? html << page : html << yield(page)
    end
 
    # Print end page if anchors are enabled
    html << yield(pagingEnum.last_page) if always_show_anchors and not last == pagingEnum.last_page
    html
  end

  def space(limit)
    ret = ""
    1.upto(limit) do |x|  
      ret += "&nbsp;"
    end
    ret
  end
  
  def break_line(limit)
    ret = ""
    1.upto(limit) do |x|  
      ret += "<br />"
    end
    ret
  end
  
  def initial_table_freeze(options = {})
    javascript_tag <<-_JS
      var freezeSize = #{options[:freeze_size]};
      var stopCell = #{options[:stop_cell]};
      var stopVertical = #{options[:stop_vertical]}
    _JS
  end
  
  def edit_redbox_url(controller, action, data)
    if action == 'index'
      "/accounting/#{controller}/edit/#{data.id}"
    else
      "#{controller}/edit/#{data.id}"
    end      
  end
  
  def flash_notice
    message = "<center><div class='clean-ok'>#{flash[:notice]}</div></center>" if flash[:notice]
    message = "<center><div class='clean-error'>#{flash[:error]}</div></center>" if flash[:error]
    message += "<script>flash_appear();</script>"
    return message
    flash[:notice] = nil
    flash[:error] = nil
  end
  
  def ajax_flash_notice
    message = "<div class='notice'>#{flash[:notice]}</div>"
    message += "<script>ajax_flash_appear();</script>"
    return message
    flash[:notice] = nil
  end
  
  #  def add_validation(object_id, validate_type, options = {})
  #    javascript_tag <<-_JS
  #      var vaidate_#{object_id} = new LiveValidation('#{object_id}');
  #      vaidate_#{object_id}.add(Validate.#{validate_type.classify}, options)
  #_JS
  #  end
  
  def concat_help_images(path_,images)     
    path_images_help_1 = path_
    path_images_help_1 = path_images_help_1.to_s+images.to_s   
    path_images_help_1
  end
  
  def set_active_remainder(remainder_obj, bol)    
    return true
    #remainder_obj.update_attribute(:alert_date,bol)
  end

  def validate_type_item
    type = []
    Type.find(:all, :conditions => ["active = ?", 1]).each do |p|
      type << "#{p.name}"
    end
    return type
  end

  def validate_unit_item
    code = []
    Unit.find(:all, :conditions => ["active = ?", 1]).each do |p|
      code << "#{p.name}"
    end
    return code
  end

  def validate_vendor
    vendors = []
    Vendor.find(:all).each do |vendor|
      vendors << "#{vendor.name}"
    end
    return vendors
  end
  
end
