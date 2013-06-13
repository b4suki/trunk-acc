# == Schema Information
# Schema version: 20081030064618
#
# Table name: user_roles
#
#  id         :integer(4)      not null, primary key
#  role_id    :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class UserRole < ActiveRecord::Base
end
