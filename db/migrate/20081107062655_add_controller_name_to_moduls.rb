class AddControllerNameToModuls < ActiveRecord::Migration
  def self.up
    add_column :moduls, :controller_name, :string
  end

  def self.down
     remove_column :moduls, :controller_name
  end
end
