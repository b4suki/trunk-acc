class CreateRoleMenuAssignments < ActiveRecord::Migration
  def self.up
    create_table :role_menu_assignments do |t|
      t.integer "role_id"
      t.integer "menu_id"
      t.timestamps
    end

    user = User.new(:id => 1, :login => "admin", :email => "admin@esitrack.com", :password => "admin", :password_confirmation => "admin")
    role = Role.new(:id => 1, :title => "Administrator")
    user.roles << role
    user.save

    RoleMenuAssignment.create(:id => 1, :role_id => 1, :menu_id => 1)
    RoleMenuAssignment.create(:id => 2, :role_id => 1, :menu_id => 2)
    RoleMenuAssignment.create(:id => 3, :role_id => 1, :menu_id => 3)
    RoleMenuAssignment.create(:id => 4, :role_id => 1, :menu_id => 4)
    RoleMenuAssignment.create(:id => 5, :role_id => 1, :menu_id => 5)
    RoleMenuAssignment.create(:id => 6, :role_id => 1, :menu_id => 6)
    RoleMenuAssignment.create(:id => 7, :role_id => 1, :menu_id => 7)
    RoleMenuAssignment.create(:id => 8, :role_id => 1, :menu_id => 8)
  end

  def self.down
    drop_table :role_menu_assignments
  end
end
