class Accounting::AccountsController < ApplicationController
  before_filter :login_required

  def index
    @account_classifications = AccountingAccountClassification.find(:all)
    @account_classification_id = params[:id]
    conditions = []
    conditions << "(parent_id is NULL)"
    if params[:id].nil?
      @account_classification_id = "1"
      conditions << "account_classification_id='1'"
    else
      conditions << "account_classification_id='#{params[:id]}'"
    end
    conditions << "parent_id IS NULL"
    conditions = conditions.join(" AND ")
    @accounts = AccountingAccount.find(:all, :conditions => conditions, :order => "code")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @accounts }
      format.pdf  { 
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "kode_rekening.pdf"
      }
      format.xls { render_to_xls(:filename => "kode_rekening.xls") }
    end
  end
 
  def destroy
    @account = AccountingAccount.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to :action => :index }
      format.xml  { head :ok }
    end
  end
  
  def edit_account
    @account = AccountingAccount.find(params[:id])
    render :update do |page|
      page.replace_html "account_#{params[:id]}", :partial => "edit_account", :locals => {:acc => @account, :level => params[:level]}
    end
  end
   
  def update_account
    @account = AccountingAccount.find(params[:account][:id])
    if @account.update_attributes(params[:account])
      render :update do |page|
        page.replace_html "account_#{params[:account][:id]}", :partial => "detail", :locals => {:acc => @account, :level => params[:level]}
      end
    else
      errors = knowing_errors(@account)
      render :update do |page|
        errors.each do |error|
          page.call "set_field_error", error
        end
      end
    end
  end
   
  def new_sub_account
    render :update do |page|
      page.replace_html "new_group_#{params[:id]}", :partial => "new_sub_account", :locals => {:id => params[:id], :level => params[:level], :account_classification_id => params[:account_classification_id]}
    end
  end
   
  def create_sub_account
    @account = AccountingAccount.new(params[:account])
    @account.parent_id = params[:id]
    if @account.save
      render :update do |page|
        page.replace "new_group_#{params[:id]}", :partial => "account", :locals => {:acc => @account, :id => params[:id], :level => params[:level]  }
        unless params[:id].nil?
          acc = AccountingAccount.find(params[:id])
          page.replace_html "account_#{params[:id]}", :partial => "detail", :locals => {:acc => acc, :level => params[:level].to_i - 1 }
        end
      end
    else
      errors = knowing_errors(@account)
      render :update do |page|
        errors.each do |error|
          page.call "set_field_error", error
        end
      end
    end
  end
   
  def cancel_form
    render :update do |page|
      page.replace_html "new_group_#{params[:id]}", ""
    end
  end
   
  def cancel_editing
    @account = AccountingAccount.find(params[:id])
    render :update do |page|
      page.replace_html "account_#{params[:id]}", :partial => "detail", :locals => {:acc => @account, :level => params[:level]}
    end
  end
   
  def new_parent
    render :update do |page|
      page.replace_html "new_group_", :partial => "new_sub_account", :locals => {:id => params[:id], :level => params[:level], :account_classification_id => params[:account_classification_id]}
    end
  end
   
  def export_excel
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = 'attachment; filename="accounts.xls"'
    @accounts = AccountingAccount.find(:all)
    render :layout => false
  end
  
  def delete_account
    @account = AccountingAccount.find(params[:id])
    parent = @account.parent
    @account.destroy
    render :update do |page|
      unless parent.nil?
        page.replace_html "account_#{parent.id}", :partial => "detail", :locals => {:acc => parent, :level => params[:level].to_i - 1 } 
      end
      #      page.replace "account_#{params[:id]}", ""
      page.remove "account_#{params[:id]}"
    end
  end
   
  private
   
  def knowing_errors(account)
    errors = []
    account.errors.each do |a,x|
      errors << a
    end
    return errors.uniq
  end
end
