class SessionToken < ActiveRecord::Base
	include Utility

	belongs_to :user

	validates_presence_of :token

	def self.app_authenticate(token)
		st_obj                 = where(token: token).first
		user                   = st_obj.user
		user.session_token_obj = st_obj
		return user
	end

end
