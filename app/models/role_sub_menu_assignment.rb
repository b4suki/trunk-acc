class RoleSubMenuAssignment < ActiveRecord::Base
  belongs_to :role_menu_assignment
  belongs_to :accounting_app_sub_menu, :foreign_key => "sub_menu_id"
end
