class CreateReportOfYears < ActiveRecord::Migration
  def self.up
    create_table :report_of_years do |t|
      t.integer :account_id
      t.date :date_report
      t.float :value

      t.timestamps
    end
  end

  def self.down
    drop_table :report_of_years
  end
end
