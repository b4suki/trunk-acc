module Accounting::CashFlowDebitCreditsHelper
  def display_cash_flow_accounts_from(cash_flow_operation_type)
    ret = ""
    ret << "<tr class='grid_1'>"
    ret << "<td style='width :340px;' align='center'>No Rekening</td>"
    ret << "<td colspan='2' align='center'>Option</td>"
    ret << "</tr>"
    cash_flow_operation_type.categories.each do |category|
      ret << "<tr class='grid_category'>"
      ret << "<td>#{category.title}</td>"
      ret << "<td align='right'>#{link_to_remote_redbox "Tambah account", {:url => "cash_flow_debit_credits/new?category_id=#{category.id}"}, :class => "a_add"}"
      ret << "#{link_to_remote_redbox "Edit", {:url => "cash_flow_categories/edit/#{category.id}"}, :class => "a_edit"}"
      ret << "</td>"
      ret << "<td>#{category.accounts.size == 0 ? link_to("Hapus", "cash_flow_categories/destroy/#{category.id}", :confirm => "Anda yakin akan menghapus kategori?", :class => "a_delete") : "&nbsp;"}</td>"
      ret << "</tr>"

      category.debit_credits.each do |debit_credit|
        ret << "<tr class=#{cycle('grid_2', 'grid_3')}>"
        ret << "<td>#{debit_credit.account.code}  #{debit_credit.account.description}</td>"
        ret << "<td align='right'>#{link_to_remote_redbox "Edit", {:url => "cash_flow_debit_credits/edit/#{debit_credit.id}"}, :class => "a_edit"}</td>"
        ret << "<td>#{link_to "Hapus", "cash_flow_debit_credits/destroy/#{debit_credit.id}", :confirm => "Anda yakin akan menghapus account?", :class => "a_delete"}</td>"
        ret << "</tr>"
      end
    end
    ret << "<tr class='grid_footer'>"
    ret << "<td colspan='3'>#{link_to_remote_redbox "Kategori baru", {:url => "cash_flow_categories/new?activity_id=#{cash_flow_operation_type.id}"}, :class => 'a_add'}"
    ret << "</tr>"
  end
end
