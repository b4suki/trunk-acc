class CreatePaymentProcedures < ActiveRecord::Migration
  def self.up
    create_table :payment_procedures do |t|
      t.string :name
      t.timestamps
    end
    execute "INSERT INTO `payment_procedures` (`name`) VALUES 
            ('Tunai '),
            ('Giro');"
  end

  def self.down
    drop_table :payment_procedures
  end
end
