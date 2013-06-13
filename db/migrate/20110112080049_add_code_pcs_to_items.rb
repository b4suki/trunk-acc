class AddCodePcsToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :code_pcs, :integer
  end

  def self.down
    remove_colum :items, :code_pcs
  end
end
