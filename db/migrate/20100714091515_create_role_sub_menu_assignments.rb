class CreateRoleSubMenuAssignments < ActiveRecord::Migration
  def self.up
    create_table :role_sub_menu_assignments do |t|
      t.integer "role_menu_assignment_id"
      t.integer "sub_menu_id"
      t.timestamps
    end
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 1, :sub_menu_id => 1)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 1, :sub_menu_id => 2)

    RoleSubMenuAssignment.create(:role_menu_assignment_id => 2, :sub_menu_id => 3)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 2, :sub_menu_id => 4)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 2, :sub_menu_id => 5)

    RoleSubMenuAssignment.create(:role_menu_assignment_id => 3, :sub_menu_id => 6)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 3, :sub_menu_id => 7)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 3, :sub_menu_id => 8)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 3, :sub_menu_id => 9)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 3, :sub_menu_id => 10)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 3, :sub_menu_id => 11)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 3, :sub_menu_id => 33)

    RoleSubMenuAssignment.create(:role_menu_assignment_id => 4, :sub_menu_id => 12)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 4, :sub_menu_id => 13)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 4, :sub_menu_id => 14)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 4, :sub_menu_id => 15)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 4, :sub_menu_id => 16)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 4, :sub_menu_id => 17)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 4, :sub_menu_id => 18)
    
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 5, :sub_menu_id => 19)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 5, :sub_menu_id => 20)

    RoleSubMenuAssignment.create(:role_menu_assignment_id => 6, :sub_menu_id => 21)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 6, :sub_menu_id => 22)

    RoleSubMenuAssignment.create(:role_menu_assignment_id => 7, :sub_menu_id => 23)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 7, :sub_menu_id => 24)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 7, :sub_menu_id => 25)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 7, :sub_menu_id => 26)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 7, :sub_menu_id => 27)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 7, :sub_menu_id => 28)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 7, :sub_menu_id => 29)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 7, :sub_menu_id => 30)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 7, :sub_menu_id => 31)
    RoleSubMenuAssignment.create(:role_menu_assignment_id => 7, :sub_menu_id => 32)
  end

  def self.down
    drop_table :role_sub_menu_assignments
  end
end
