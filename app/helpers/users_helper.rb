module UsersHelper
  def set_check_box_role(user)
    roles = user.roles.collect{|p| p.id}
    ret = ""
    Role.find(:all).each do |role|
      ret << "#{radio_button_tag(:role, role.id, roles.include?(role.id) ? true : false)}  #{role.title}<br />"
    end
    ret
  end
end