class UserSocial < ActiveRecord::Base
  attr_accessible :identifier, :type, :user_id
end
