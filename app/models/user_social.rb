class UserSocial < ActiveRecord::Base
  attr_accessible :identifier, :type_of, :user_id

  belongs_to :user

  validates_presence_of :identifier, :type_of, :user_id
end
