class AccountingAppMenu < ActiveRecord::Base
  has_many :sub_menu, :class_name => "AccountingAppSubMenu", :foreign_key => "menu_id"
  has_many :role_menu_assignments, :foreign_key => "menu_id"
end
