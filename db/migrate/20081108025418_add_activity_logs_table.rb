class AddActivityLogsTable < ActiveRecord::Migration
  def self.up
    create_table :activity_logs, :options => "DEFAULT CHARSET = utf8" do |t|
      # Thanks to 'Justin' for an updated migration script, much cleaner!
      t.belongs_to :user 
      t.string :action 
      t.references :activity_loggable, :null => true, :polymorphic => true 
      t.references :culprit, :null => true, :polymorphic => true 
      t.references :referenced, :null => true, :polymorphic => true 
      t.timestamps 
    end
  end

  def self.down
    drop_table :activity_logs
  end
end