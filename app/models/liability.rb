class Liability < AccountingMutation
  belongs_to :purchase, :class_name => "AccountingPurchaseBalance", :foreign_key => "transaction_id"
end