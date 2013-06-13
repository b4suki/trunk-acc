class Accounting::AdjustmentsController < ApplicationController
  before_filter :initial_method
  skip_before_filter :verify_authenticity_token, :only => [
    :multi_auto_complete_for_account_debit,
    :multi_auto_complete_for_account_credit]

  def index
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end

    @date = params[:date] ? params[:date] : {:month => current_month, :year => current_year}
    conditions = []
    conditions << "MONTH(created_at) = #{@date[:month]}"
    conditions << "YEAR(created_at) = #{@date[:year]}"
    conditions = conditions.join(" AND ")
    $CONDITIONS_DATE = conditions

    @adjustment_entries = AccountingAdjustment.find(:all, :conditions => conditions, :order => "created_at")

    respond_to do |format|
      format.html
      format.xml {render :xml => @adjustment_entries}
      format.pdf {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "adjustment_entries_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "adjustment_entries_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  def new
    @adjustment_entry = AccountingAdjustment.new
    @index_debit = 1
    @index_credit = 1
    render :layout => false
  end

  def create
    @adjustment_entry = AccountingAdjustment.new(params[:adjustment_entry])
    @adjustment_entry.created_at = params[:adjustment_entry_created_at]

    1.upto(params[:debit_count].to_i) do |i|
      if params["debit_account_id_#{i}"]!=""
        debit_journal = AccountingJournalValue.new(
          :account_id => params["debit_account_id_#{i}"],
          :value => params["value_debit_#{i}"],
          :is_debit => true
        )
        @adjustment_entry.values << debit_journal
      end
    end

    1.upto(params[:credit_count].to_i) do |i|
      if params["credit_account_id_#{i}"]!=""
        credit_journal = AccountingJournalValue.new(
          :account_id => params["credit_account_id_#{i}"],
          :value => params["value_credit_#{i}"],
          :is_debit => false
        )
        @adjustment_entry.values << credit_journal
      end
    end

    respond_to do |format|
      if @adjustment_entry.save
        flash[:notice] = "Adjustment berhasil dibuat"
      else
        flash[:error] = "Adjustment journal gagal dibuat"
      end
      format.html {redirect_to accounting_adjustments_path}
    end
  end

  def edit
    @adjustment_entry = AccountingAdjustment.find(params[:id])
    @debit_values = AccountingJournalValue.find_all_by_journal_id_and_is_debit(params[:id], true)
    @credit_values = AccountingJournalValue.find_all_by_journal_id_and_is_debit(params[:id], false)
    render :layout => false
  end

  def update
    @adjustment_entry = AccountingAdjustment.find(params[:id])
    @adjustment_entry.created_at = params[:adjustment_entry_created_at]
    @adjustment_entry.values.each do |value|
      value.destroy
    end

    1.upto(params[:debit_count].to_i) do |i|
      if params["debit_account_id_#{i}"]!=""
        debit_journal = AccountingJournalValue.new(
          :account_id => params["debit_account_id_#{i}"],
          :value => params["value_debit_#{i}"],
          :is_debit => true
        )
        @adjustment_entry.values << debit_journal
      end
    end

    1.upto(params[:credit_count].to_i) do |i|
      if params["credit_account_id_#{i}"]!=""
        credit_journal = AccountingJournalValue.new(
          :account_id => params["credit_account_id_#{i}"],
          :value => params["value_credit_#{i}"],
          :is_debit => false
        )
        @adjustment_entry.values << credit_journal
      end
    end

    respond_to do |format|
      if @adjustment_entry.update_attributes(params[:adjustment_entry])
        flash[:notice] = "Adjustment berhasil diupdate"
      else
        flash[:error] = "Adjustment journal gagal diupdate"
      end
      format.html {redirect_to accounting_adjustments_path}
    end
  end

  def add_debit
    render :update do |page|
      page.insert_html :before, "end-of-debit-account",
        :partial => "debit_account_detail",
        :locals => {:index => params[:index], :size => params[:size]}
      page.replace_html "end-of-debit-account",
        :partial => "add_new_debit",
        :locals => {:index => params[:index], :size => params[:size]}
      page << "$('debit_count').value=#{params[:index].to_i}"
    end
  end

  def add_credit
    render :update do |page|
      page.insert_html :before, "end-of-credit-account",
        :partial => "credit_account_detail",
        :locals => {:index => params[:index], :size => params[:size]}
      page.replace_html "end-of-credit-account",
        :partial => "add_new_credit",
        :locals => {:index => params[:index], :size => params[:size]}
      page << "$('credit_count').value=#{params[:index].to_i}"
    end
  end
  
  def multi_auto_complete_for_account_credit
    search = params["account_credit_#{params[:index]}"]
    accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "shared/autocomplete", :locals => {:accounts => accounts}
  end

  def multi_auto_complete_for_account_debit
    search = params["account_debit_#{params[:index]}"]
    accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "shared/autocomplete", :locals => {:accounts => accounts}
  end

  def destroy
    @adjustment_entry = AccountingAdjustment.find(params[:id])
    @adjustment_entry.destroy

    redirect_to accounting_adjustments_path
  end

  def adjust_account
    accounts = AccountingAccount.find(:all, :conditions => ["parent_id is NULL"], :order => "code ASC")
    current_period = {:month => "", :year => ""}
    current_period = {:month => current_month , :year => current_year}

    date = params[:adjustment] ? Time.mktime(params[:adjustment][:year], params[:adjustment][:month], 1, 0, 0, 0, 0) : Time.now
    current_period = {:month => date.strftime("%m"), :year => date.strftime("%Y")}
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}

    conditions = []
    conditions << "MONTH(created_at)=#{current_period[:month]}"
    conditions << "YEAR(created_at) = #{current_period[:year]}"
    conditions = conditions.join(" AND ")
    $CONDITIONS_DATE = conditions
    adjustments = AccountingAdjustment.find(:all, :conditions => conditions )


    prepare_adjustment(accounts, adjustments, previous_date, current_period, false)
    redirect_to :action => "index"
  end

  private

  def prepare_adjustment(groups, result, previous_date, date, report = false)
    level = 0
    $SUMMARY_PREVIOUS = 0
    $SUMMARY_DEBET    = 0
    $SUMMARY_CREDIT   = 0
    $SUMMARY_SALDO    = 0

    for group in groups
      if group.parent_id.nil?
        first_saldo = get_current_saldo(group, date)
        summary = prepare_show_summary(result, group, false, false)
        if group.accounting_account_classification.is_debit
          last_saldo       = first_saldo+(summary[1]-summary[0])
        else
          last_saldo       = first_saldo+(summary[0]-summary[1])
        end
        $SUMMARY_PREVIOUS += first_saldo
        $SUMMARY_DEBET    += summary[1]
        $SUMMARY_CREDIT   += summary[0]
        $SUMMARY_SALDO    += last_saldo
        create_adjustment(group, last_saldo, date)
        find_all_sub_account_prepare_adjustment(result,previous_date,date, group, level, report)
      end
    end
    update_history_stock_item(date)
  end

  def find_all_sub_account_prepare_adjustment(result,previous_date, date, group, level, report)
    level += 1
    group.children.each do |sugroup|
      first_saldo = get_current_saldo(sugroup, date)
      summary = prepare_show_summary(result, sugroup,false, false)
      if group.accounting_account_classification.is_debit
        as_adjusted       = first_saldo+(summary[1]-summary[0])
      else
        as_adjusted       = first_saldo+(summary[0]-summary[1])
      end
      $SUMMARY_PREVIOUS += first_saldo
      $SUMMARY_DEBET    += summary[1]
      $SUMMARY_CREDIT   += summary[0]
      $SUMMARY_SALDO    += as_adjusted
      create_adjustment(sugroup, as_adjusted, date)
      find_all_sub_account_prepare_adjustment(result,previous_date,date,sugroup, level, report)
      update_adjustment_stock_inventories(as_adjusted, date)
    end
  end

  def prepare_show_summary(result, account, debit, credit)
    account = {:select => false, :value => account.id}
    summary = []
    summary_debet = 0
    summary_credit = 0
    result.each do |journal|
      summary = summary_general_journal_from_adjustment_entry(journal, account, debit, credit)
      summary_credit += summary[0]
      summary_debet += summary[1]
    end
    return summary_credit, summary_debet
  end

  def summary_general_journal_from_adjustment_entry(journal, account, debit, credit)
    ret_debet = 0
    ret_kredit = 0
    if(!debit && !credit)
      journal.values.each do |value|
        if value.account_id == account[:value].to_i
          if value.is_debit
            ret_debet += value.value
          elsif !value.is_debit
            ret_kredit += value.value
          end
        end
      end
    end
    return ret_kredit, ret_debet
  end

  def get_current_saldo(group, period)
    first_saldo = group.trial_balances.find(
      :first,
      :conditions => ["MONTH(transaction_date)=#{period[:month]} AND YEAR(transaction_date)=#{period[:year]}"]
    )
    first_saldo = first_saldo.nil? ? 0 : first_saldo.last_saldo
  end

  def create_adjustment(group, as_adjusted_value, date)
    first_saldo = group.trial_balances.find(
      :first,
      :conditions => "MONTH(transaction_date) = #{date[:month]} AND YEAR(transaction_date) = #{date[:year]}"
    )
    report = ReportOfYear.find( :first,:conditions => ["YEAR(date_report) = #{date[:year]} AND account_id = '#{group.id}'"])
    if report.nil?
      ReportOfYear.create(:account_id => group.id,:value => as_adjusted_value, :date_report => Time.mktime(date[:year], 12, 6, 0, 0, 0, 0))
    else
      report.update_attribute(:value, as_adjusted_value)
    end
    if first_saldo.nil?
      trial_balance = TrialBalance.new(:as_adjusted => as_adjusted_value, :transaction_date => Time.mktime(date[:year], date[:month], 6, 0, 0, 0, 0))
      group.trial_balances << trial_balance
      group.save
    else
      first_saldo.update_attribute(:as_adjusted, as_adjusted_value)
    end
  end

  def update_adjustment_stock_inventories(as_adjusted_value, date)
    check_inventory = TrialBalance.find(:first,:conditions => ["MONTH(transaction_date) = #{date[:month]} AND YEAR(transaction_date) = #{date[:year]} AND account_id = 12"])
    #    stock_last = Item.find(:all, :conditions => ["items.active='1'"]).sum(&:total_value)
    stock_last = Item.find(:all, :conditions => ["MONTH(created_at) = #{date[:month]} AND YEAR(created_at) = #{date[:year]}  AND items.active='1'"]).sum(&:total_value)
    if check_inventory.blank?
      inventories = TrialBalance.new(:as_adjusted => as_adjusted_value += stock_last, :account_id => "12", :transaction_date => Time.mktime(date[:year], date[:month], 6, 0, 0, 0, 0))
      inventories.save
    else
      check_inventory.update_attribute(:as_adjusted, as_adjusted_value + stock_last)
    end
  end

  def update_history_stock_item(date)
    date_after = Time.mktime(date[:year], date[:month].to_i + 1, 6, 0, 0, 0, 0)
    date_after = {:month => date_after.strftime("%m"), :year => date_after.strftime("%Y")}
    conditions = []
    conditions << "MONTH(invoice_date) = #{date_after[:month]}"
    conditions << "YEAR(invoice_date) = #{date_after[:year]}"
    conditions = conditions.join(" AND ")
    purchases = AccountingPurchaseBalance.find(:all ,:conditions => conditions)
    sales = AccountingSaleBalance.find(:all ,:conditions => conditions)
   
    items = Item.find(:all, :conditions => ["items.active='1'"])
    items.each do |item|
      check_history = ItemHistory.find(:first,:conditions => ["MONTH(last_date) = #{date[:month]} AND YEAR(last_date) = #{date[:year]} AND item_id = '#{item.id}'"])
      if check_history.blank? || check_history.nil?
        ItemHistory.create(:item_id => item.id, :last_date => Time.mktime(date[:year], date[:month], 6, 0, 0, 0, 0), :last_stock => item.stock,:value =>  item.total_value)
      else
        total_qty_purchase ,total_qty_sale, price_purchase, price_sale = 0, 0, 0, 0
        purchases.each { |purchase| 
          total_qty_purchase +=  purchase.accounting_purchase_balance_details.collect { |e| e.qty if e.item_id == item.id }.sum
          price_purchase +=  purchase.accounting_purchase_balance_details.collect { |e| e.price * e.qty if e.item_id == item.id }.sum}
        sales.each { |sale| total_qty_sale +=  sale.accounting_sale_balance_details.collect { |e| e.qty if e.item_id == item.id }.sum
          price_sale +=  sale.accounting_sale_balance_details.collect { |e| e.price * e.qty if e.item_id == item.id }.sum}
      
        check_history.update_attributes(:last_stock => (item.stock + total_qty_sale) - total_qty_purchase ,:value =>  (item.total_value + price_sale ) - price_purchase )
      end
    end
   
  end

  def initial_method
    @title = "ADJUSTMENT ENTRY"
    @periode = true
  end
end
