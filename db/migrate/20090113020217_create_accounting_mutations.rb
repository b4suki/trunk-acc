class CreateAccountingMutations < ActiveRecord::Migration
  def self.up
    create_table :accounting_mutations do |t|      
      t.string :type
      t.column :payed_value, :double
      t.column :last_value, :double
      t.integer :transaction_id, :vendor_customer_id
      t.timestamps
    end
  end  

  def self.down
    drop_table :accounting_mutations
  end
end
