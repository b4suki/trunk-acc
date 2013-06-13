module BalanceSheetHelper
  def display_current_asset(date)    
    ret = ""
    $TOTAL_CURRENT_ASSET = 0
    asset_accounts = AccountingAccountClassification.find_by_name("Harta").accounting_accounts
    asset_accounts.each do |account|
      result = prepare_current_saldo(account.description, date, account, "", 0)
      ret += result[0]
      $TOTAL_CURRENT_ASSET += result[1]
    end
    ret
  end

  def display_current_fixed_asset(date)
    ret = ""
    $TOTAL_CURRENT_FIXED_ASSET = 0
    building_account = AccountingAccount.find_by_code(13100)
    deprec_building_account = AccountingAccount.find_by_code(13101)
    machineries_account = AccountingAccount.find_by_code(13200)
    deprec_machineries_account = AccountingAccount.find_by_code(13201)
    equipment_and_computer_account = AccountingAccount.find_by_code(13300)
    deprec_equipment_and_computer_account = AccountingAccount.find_by_code(13301)
    furniture_account = AccountingAccount.find_by_code(13400)
    deprec_furniture_account = AccountingAccount.find_by_code(13401)
    metrologi_account = AccountingAccount.find_by_code(13500)
    deprec_metrologi_account = AccountingAccount.find_by_code(13501)
    vehicle_account = AccountingAccount.find_by_code(13600)
    deprec_vehicle_account = AccountingAccount.find_by_code(13601)
    
    result = prepare_current_saldo("Building", date, building_account,ret ,$TOTAL_CURRENT_FIXED_ASSET)
    result = prepare_current_saldo("Acc. Deprec. Building", date, deprec_building_account, result[0], result[1])
    result = prepare_current_saldo("Machineries", date, machineries_account, result[0], result[1])
    result = prepare_current_saldo("Acc. Deprec. Machineries", date, deprec_machineries_account, result[0], result[1])
    result = prepare_current_saldo("Electricity Equipment and Computer", date, equipment_and_computer_account, result[0], result[1])
    result = prepare_current_saldo("Acc. Deprec. Machineries", date, deprec_equipment_and_computer_account, result[0], result[1])
    result = prepare_current_saldo("Furniture and Office Equipment", date, furniture_account, result[0], result[1])
    result = prepare_current_saldo("Acc. Deprec. Furniture and Office Equip.", date, deprec_furniture_account, result[0], result[1])
    result = prepare_current_saldo("Alat Ukur dan Alat Metrologi lainnya", date, metrologi_account, result[0], result[1])
    result = prepare_current_saldo("Acc. Deprec.", date, deprec_metrologi_account, result[0], result[1])
    result = prepare_current_saldo("Vehicle.", date, vehicle_account, result[0], result[1])
    result = prepare_current_saldo("Acc. Deprec. Vehicles.", date, deprec_vehicle_account, result[0], result[1])
    $TOTAL_CURRENT_FIXED_ASSET = result[1]
    ret = result[0]
  end

  def display_other_asset(date)
    ret = ""
    $TOTAL_CURRENT_OTHER_ASSET = 0
    bank_garanty_account = AccountingAccount.find_by_code(14100)
    cash_advance_account = AccountingAccount.find_by_code(14200)
    deffered_charges_account = AccountingAccount.find_by_code(14300)
    ppn_masukan_account = AccountingAccount.find_by_code(15100)
    ppn_22_account = AccountingAccount.find_by_code(15200)
    ppn_23_account = AccountingAccount.find_by_code(15300)
    ppn_25_account = AccountingAccount.find_by_code(15400)
    result = prepare_current_saldo("Bank Garanty", date, bank_garanty_account,ret ,$TOTAL_CURRENT_OTHER_ASSET)
    result = prepare_current_saldo("Cash Advance", date, cash_advance_account, result[0], result[1])
    result = prepare_current_saldo("Deffered Charges", date, deffered_charges_account, result[0], result[1])
    result = prepare_current_saldo("PPN Masukan", date, ppn_masukan_account, result[0], result[1])
    result = prepare_current_saldo("PPh pasal 22", date, ppn_22_account, result[0], result[1])
    result = prepare_current_saldo("PPh pasal 23", date, ppn_23_account, result[0], result[1])
    result = prepare_current_saldo("PPh pasal 25", date, ppn_25_account, result[0], result[1])
    $TOTAL_CURRENT_OTHER_ASSET = result[1]
    ret = result[0]
  end
  
  def display_liabilities(date)
    ret = ""
    $TOTAL_LIABILITIES = 0
    payable_accounts = AccountingAccountClassification.find_by_name("Utang").accounting_accounts
    payable_accounts.each do |account|
      result = prepare_current_saldo(account.description, date, account, "" ,0)
      ret << result[0]
      $TOTAL_LIABILITIES += result[1]
    end
    ret
  end

  def display_capital(date)
    ret =""
    $TOTAL_CAPITAL = 0
    capital_accounts = AccountingAccountClassification.find_by_name("Modal").accounting_accounts
    capital_accounts.each do |account|
      result = prepare_current_saldo(account.description, date, account, "" ,0)
      ret << result[0]
      $TOTAL_CAPITAL += result[1]
    end
    ret
  end
  
  def prepare_current_saldo(header, date, account, ret, total )
    result = get_as_adjusted_saldo(account, date)
    total += result
    template_balance_sheet(header, ret, result)
    return ret, total
  end
  
  def template_balance_sheet(header, ret, result)
    ret << "<tr class='grid_2'>"
    ret << "<td>#{create_space(1)}#{header}</td>"
    ret << "<td align='right'>#{format_currency(result)}</td>"
    ret << "</tr>"
    ret
  end
  
  def get_first_saldo_balance(group, previous_date)
    first_saldo = group.trial_balances.find(
      :first, 
      :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]}"]
    )
    first_saldo = first_saldo.nil? ? 0 : first_saldo.last_saldo
  end

  def get_summary_balance_sheet(account, date)
    aje_debet = 0
    aje_credit = 0
    accounting_fixed_asset_detail = AccountingFixedAssetDetail.find(:first, :conditions => ["MONTH(transaction_date) = '#{date[:month]}' AND YEAR(transaction_date) = '#{date[:year]}' AND account_id =? ", account.id])
    unless accounting_fixed_asset_detail.nil?
      if accounting_fixed_asset_detail.accounting_fixed_asset.adjustment_account.debit_credit == false
        aje_debet = 0
        aje_credit = accounting_fixed_asset_detail.aje_values
      else
        aje_debet = accounting_fixed_asset_detail.aje_values
        aje_credit = 0
      end
    end
    ajs_balances = AccountingAdjustmentBalance.find(:first, :conditions => ["MONTH(adjustment_date) = '#{date[:month]}' AND YEAR(adjustment_date) = '#{date[:year]}' AND account_id =? ", account.id])
    if !ajs_balances.nil? && account.account_type == "debet"
      aje_debet += ajs_balances.values
      aje_credit += ajs_balances.values unless ajs_balances.contra_account_id.nil?
    elsif !ajs_balances.nil?
      aje_credit += ajs_balances.values
      aje_debet += ajs_balances.values unless ajs_balances.contra_account_id.nil?
    end
    return aje_debet, aje_credit
  end
  
end
