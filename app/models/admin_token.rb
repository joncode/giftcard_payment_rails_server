class AdminToken < ActiveRecord::Base
  attr_accessible :token

  validates_presence_of   :token
  validates_uniqueness_of :token
end
