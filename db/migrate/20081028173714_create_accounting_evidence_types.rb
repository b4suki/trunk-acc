class CreateAccountingEvidenceTypes < ActiveRecord::Migration
  def self.up
    create_table :accounting_evidence_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_evidence_types
  end
end
