class UserSocial < ActiveRecord::Base
  attr_accessible :identifier, :type_of, :user_id

  validates_presence_of :identifier, :type_of, :user_id
end
