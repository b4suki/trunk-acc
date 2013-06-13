class AccountingAppSubMenu < ActiveRecord::Base
  belongs_to :app_menu, :class_name => "AccountingAppMenu", :foreign_key => "menu_id"
  has_many :role_sub_menu_assignments, :foreign_key => "sub_menu_id"
end
