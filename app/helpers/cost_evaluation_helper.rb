module CostEvaluationHelper
  def display_account_on_cost_evaluation(groups)
    level = 0
    ret = ""
    for group in groups
      if group.parent_id.nil?
        create_tabel(ret,group, nil)
        ret << find_all_sub_account_on_cost_evaliation(group, level)
      end
    end
    ret
  end

  def find_all_sub_account_on_cost_evaliation(group, level)
    level += 1
    ret = ""
    group.children.each do |sugroup|
      create_tabel(ret,group, level)
      ret << find_all_sub_account_on_cost_evaliation(sugroup, level)
    end
    ret
  end

  def create_tabel(ret,group, level)
    ret << "<tr class=#{cycle("grid_2","grid_3")} id=\"account_#{group.id}\">"
    ret << "<td style=\"text-align:center;\"> #{group.code_a}</td>"
    ret << "<td style=\"text-align:center;\"> #{group.code_b}</td>"
    ret << "<td style=\"text-align:center;\"> #{group.code_c}</td>"
    ret << "<td style=\"text-align:center;\"> #{group.code_d}</td>"
    ret << "<td style=\"text-align:center;\"> #{group.code_e}</td>"
    ret << !level.nil? ? "<td><div style=\"width:#{level*25}px;height:20px;float:left;\"></div>#{group.description}</td>" : "<td width='400px'> &nbsp;#{group.description}</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>&nbsp;</td>"
    ret << "</tr>"
    return ret
  end
end
