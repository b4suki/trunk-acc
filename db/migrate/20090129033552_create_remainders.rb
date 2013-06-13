class CreateRemainders < ActiveRecord::Migration
  def self.up
    create_table :remainders do |t|
      t.string :task_name, :description
      t.date :task_date, :alert_date         
      t.timestamps
    end
  end

  def self.down
    drop_table :remainders
  end
end
