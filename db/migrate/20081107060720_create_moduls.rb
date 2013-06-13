class CreateModuls < ActiveRecord::Migration
  def self.up
    create_table :moduls do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :moduls
  end
end
