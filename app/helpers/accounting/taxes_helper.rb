module Accounting::TaxesHelper
  def display_single_tax(title, tax, account_type)
    ret = "<tr class='grid_footer'><td colspan='6'>#{title}</td></tr>"
    if tax
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td>#{tax.description}</td>"
      ret << "<td>#{tax.account.code}</td>"
      ret << "<td>#{tax.account.description}</td>"
      ret << "<td>#{tax.rate} %</td>"
      ret << "<td>#{link_to_remote_redbox("Edit",{:url => "/accounting/taxes/edit/#{tax.id}"},{:class => "a_edit"})}</td>"
      ret << "<td>#{link_to 'Hapus', accounting_taxis_path(tax.id), :confirm => "Apakah anda yakin '#{tax.description}' akan dihapus?", :method => :delete , :class => "a_delete"}</td>"
      ret << "</tr>"
    else
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td colspan='6'>Belum Ditentukan #{link_to_remote_redbox("Input #{title}", {:url => {:action => :new, :account_type => account_type, :title => title}}, {:class => "a_add"})}</td>"
      ret << "</tr>"
    end
    return ret
  end
end
