class Rule < ActiveRecord::Base
  belongs_to :action
  belongs_to :modul
  belongs_to :role
end
