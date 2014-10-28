class SessionToken < ActiveRecord::Base
	extend Utility

	belongs_to :user

	validates_presence_of :token

	def self.app_authenticate(token)
		st_obj = where(token: token).last
		if st_obj
			user = st_obj.user
			if user.active
				user.session_token_obj = st_obj
				return user
			end
		end
		return nil
	end

	def self.create_token_obj (user, platform, pn_token=nil)
		Resque.enqueue(CreatePnTokenJob, user.id, pn_token, platform) if pn_token
		SessionToken.create(user_id: user.id, token: create_session_token, platform: platform, push: pn_token)
	end

end
