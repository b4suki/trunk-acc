class Receivable < AccountingMutation
  belongs_to :sale, :class_name => "AccountingSaleBalance", :foreign_key => "transaction_id"
  
end
