class RoleMenuAssignment < ActiveRecord::Base
  belongs_to :role
  belongs_to :accounting_app_menu, :foreign_key => "menu_id"
  has_many :role_sub_menu_assignments
end
