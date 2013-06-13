class Modul < ActiveRecord::Base
  has_many :actions, :dependent => :destroy
  has_many :rules, :dependent => :destroy
end
