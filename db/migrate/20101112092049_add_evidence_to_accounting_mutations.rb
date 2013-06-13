class AddEvidenceToAccountingMutations < ActiveRecord::Migration
  def self.up
    add_column :accounting_mutations, :evidence, :string
  end

  def self.down
    remove_column :accounting_mutations, :evidence
  end
end
