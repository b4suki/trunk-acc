# == Schema Information
# Schema version: 20081030064618
#
# Table name: roles
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :rules, :dependent => :destroy
  has_many :menu_assignments, :class_name => "RoleMenuAssignment", :foreign_key => "role_id"
  validates_presence_of :title
end
