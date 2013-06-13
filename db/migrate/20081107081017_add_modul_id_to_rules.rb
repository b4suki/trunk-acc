class AddModulIdToRules < ActiveRecord::Migration
  def self.up
    add_column :rules, :modul_id, :integer
  end

  def self.down
    remove_column :rules, :modul_id
  end
end
