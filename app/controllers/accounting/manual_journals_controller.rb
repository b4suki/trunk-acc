class Accounting::ManualJournalsController < ApplicationController
  before_filter :initial_method
  skip_before_filter :verify_authenticity_token, :only => [
    :auto_complete_for_account_code, :multi_auto_complete_for_account_debit,
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

    @date = params[:date] ? params[:date] :  {:month => current_month, :year => current_year}
    $SELECTED_ACCOUNT_PURCHASE = nil
    $FILTER_ACCOUNT_PURCHASE = false
    $FILTER_ACCOUNT_SALE = false
    conditions = []
    conditions << "MONTH(created_at) = #{@date[:month]}"
    conditions << "YEAR(created_at) = #{@date[:year]}"
    conditions = conditions.join(" AND ")
    $CONDITIONS_DATE = conditions

    @manual_journals = AccountingManualJournal.find(:all, :conditions => conditions, :order => "created_at")

    respond_to do |format|
      format.html
      format.xml {render :xml => @manual_journals}
      format.pdf  {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "manual_journal_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "manual_journal_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  def new
    @manual_journal = AccountingManualJournal.new
    @index_debit = 1
    @index_credit = 1
    render :layout => false
  end

  def create
    @manual_journal = AccountingManualJournal.new(params[:manual_journal])
    @manual_journal.created_at = params[:manual_journal_created_at]

    1.upto(params[:debit_count].to_i) do |i|
      if params["debit_account_id_#{i}"]!=""
        debit_journal = AccountingJournalValue.new(
          :account_id => params["debit_account_id_#{i}"],
          :value => params["value_debit_#{i}"],
          :is_debit => true
        )
        @manual_journal.values << debit_journal
      end
    end

    1.upto(params[:credit_count].to_i) do |i|
      if params["credit_account_id_#{i}"]!=""
        credit_journal = AccountingJournalValue.new(
          :account_id => params["credit_account_id_#{i}"],
          :value => params["value_credit_#{i}"],
          :is_debit => false
        )
        @manual_journal.values << credit_journal
      end
    end

    respond_to do |format|
      if @manual_journal.save
        flash[:notice] = "Manual journal berhasil dibuat"
      else
        flash[:error] = "Manual journal gagal dibuat"
      end
      format.html {redirect_to accounting_manual_journals_path}
    end
  end

  def edit
    @manual_journal = AccountingManualJournal.find(params[:id])
    @debit_values = AccountingJournalValue.find_all_by_journal_id_and_is_debit(params[:id], true)
    @credit_values = AccountingJournalValue.find_all_by_journal_id_and_is_debit(params[:id], false)
    render :layout => false
  end

  def update
    @manual_journal = AccountingManualJournal.find(params[:id])
    @manual_journal.created_at = params[:manual_journal_created_at]
    @manual_journal.values.each do |value|
      value.destroy
    end

    1.upto(params[:debit_count].to_i) do |i|
      if params["debit_account_id_#{i}"]!=""
        debit_journal = AccountingJournalValue.new(
          :account_id => params["debit_account_id_#{i}"],
          :value => params["value_debit_#{i}"],
          :is_debit => true
        )
        @manual_journal.values << debit_journal
      end
    end

    1.upto(params[:credit_count].to_i) do |i|
      if params["credit_account_id_#{i}"]!=""
        credit_journal = AccountingJournalValue.new(
          :account_id => params["credit_account_id_#{i}"],
          :value => params["value_credit_#{i}"],
          :is_debit => false
        )
        @manual_journal.values << credit_journal
      end
    end

    respond_to do |format|
      if @manual_journal.update_attributes(params[:manual_journal])
        flash[:notice] = "Manual journal berhasil diupdate"
      else
        flash[:error] = "Manual journal gagal diupdate"
      end
      format.html {redirect_to accounting_manual_journals_path}
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

  def auto_complete_redbox_account_code
    @accounts = AccountingAccount.find(:all)
    render :update do |page|
      page.insert_html :top, "RB_window", :partial => "autocomplete_account_code",
        :locals => {
        :type => params[:type],
        :index => params[:index]
      }
      page.call "setTopPositionRedBox", 'RB_window'
    end
  end

  def auto_complete_for_account_code
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
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
    @manual_journal = AccountingManualJournal.find(params[:id])
    if @manual_journal.destroy
      flash[:notice] = "Manual jurnal berhasil dihapus"
    else
      flash[:notice] = "Manual jurnal gagal dihapus"
    end
    respond_to do |format|
      format.html { redirect_to accounting_manual_journals_path }
      format.xml  { head :ok }
    end
  end

  private

  def initial_method
    @title = "MANUAL JOURNAL"
    @periode = true
  end
  
end
