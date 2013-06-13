class Action < ActiveRecord::Base
  belongs_to :modul
  has_many :rules
end
