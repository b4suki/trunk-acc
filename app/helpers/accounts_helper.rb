module AccountsHelper

  def get_parent_code(parent)
    parent = AccountingAccount.find(parent)
    parent ? parent.code_a : ""
  end
  
  def display_account(groups, report = false)
    level = 0
    ret = "<table  width='1000px;' class='main_table' cellpadding='0' cellspacing='0'>"
    ret << "<tr id=\"new_group_\">"
    ret << "</tr>"
    for group in groups
      if group.parent_id.nil?
        ret << "<tr class=#{cycle("grid_2","grid_3")} id=\"account_#{group.id}\">"
          ret << "<td width='20' style=\"text-align:center;\"> #{group.code_a}</td>"
          ret << "<td width='20' style=\"text-align:center;\"> #{group.code_b}</td>"
          ret << "<td width='20' style=\"text-align:center;\"> #{group.code_c}</td>"
          ret << "<td width='20' style=\"text-align:center;\"> #{group.code_d}</td>"
          ret << "<td width='20' style=\"text-align:center;\"> #{group.code_e}</td>"
          ret << "<td width='400'> #{group.description}</td>"
          ret << "<td width='200'> &nbsp;#{group.notes}</td>"
          unless report
            ret << "<td id=\"option_#{group.id}\" style=\"text-align:left;\">"
              ret << "#{link_to_remote "Tambah", :url => {:action => :new_sub_account, :id => group.id, :level => level + 1, :account_classification_id => group.account_classification_id }, :html => {:class => 'a_add'} }"
              ret << " | #{link_to_remote "Edit", :url => {:action => :edit_account, :id => group.id, :level => level}, :html => {:class => 'a_edit'} }"
              ret << " | #{link_to_remote "Hapus", :url => {:action => :delete_account, :id => group.id, :level => level}, :confirm => "Anda Yakin Akan Menghapus data '#{group.description}'?", :html => {:class => 'a_delete'}}"  if group.children.empty?
            ret << "</td>"
          end  
        ret << "</tr>"
        ret << find_all_sub_account(group, level, report)
      end
    end
    ret << "</table>"
  end
  
  def find_all_sub_account(group, level, report)
    level += 1
    ret = ""
    ret << "<tr id=\"new_group_#{group.id}\"></tr>"
    group.children.each do |sugroup|    
      ret << "<tr class=#{cycle("grid_2","grid_3")} id=\"account_#{sugroup.id}\">"      
        ret << "<td style=\"text-align:center;\"> #{sugroup.code_a}</td>"
        ret << "<td style=\"text-align:center;\"> #{sugroup.code_b}</td>"
        ret << "<td style=\"text-align:center;\"> #{sugroup.code_c}</td>"
        ret << "<td style=\"text-align:center;\"> #{sugroup.code_d}</td>"
        ret << "<td style=\"text-align:center;\"> #{sugroup.code_e}</td>"
        ret << "<td>#{sugroup.description}</td>" unless report
        ret << "<td>#{create_space(level)}#{sugroup.description}</td>" if report
        ret << "<td>#{sugroup.notes}</td>"
        unless report
          ret << "<td id=\"option_#{sugroup.id}\" style=\"text-align:left;\">"
            ret << "#{link_to_remote "Tambah", :url => {:action => :new_sub_account, :id => sugroup.id, :level => level + 1}, :html => {:class => 'a_add'} }"
            ret << "  | #{link_to_remote "Edit", :url => {:action => :edit_account, :id => sugroup.id, :level => level}, :html => {:class => 'a_edit'} }"
            ret << "  | #{link_to_remote "Hapus", :url => {:action => :delete_account, :id => sugroup.id, :level => level}, :confirm => "Kamu Yakin Akan Menghapus data '#{sugroup.description}'?", :html => {:class => 'a_delete'}}"  if sugroup.children.empty?           
          ret << "</td>"
        end  
      ret << "</tr>"
      ret << find_all_sub_account(sugroup, level, report)
    end
    ret
  end
  
  def create_space(level)
    a = ""
    0.upto(level) do |i|
      a += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
    end
    a
  end
  
end
