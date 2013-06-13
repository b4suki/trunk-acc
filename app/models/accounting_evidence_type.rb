# == Schema Information
# Schema version: 20081030064618
#
# Table name: accounting_evidence_types
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class AccountingEvidenceType < ActiveRecord::Base
end
