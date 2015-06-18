class SessionToken < ActiveRecord::Base
	extend Utility

#   -------------

	validates_presence_of :token

#   -------------

	belongs_to :user

#   -------------

	def self.app_authenticate(token)
		st_obj = where(token: token).includes(:user).last
		if st_obj
			user = st_obj.user
			if user && user.active
				user.session_token_obj = st_obj
				return user
			else
				return nil
			end
		end
		return nil
	end

	def self.create_token_obj (user, platform=nil, pn_token=nil)
		Resque.enqueue(CreatePnTokenJob, user.id, pn_token, platform) if pn_token
		SessionToken.create(user_id: user.id, token: create_session_token, platform: platform, push: pn_token)
	end

end
# == Schema Information
#
# Table name: session_tokens
#
#  id         :integer         not null, primary key
#  token      :string(255)
#  user_id    :integer
#  device_id  :integer
#  platform   :string(255)
#  push       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

