class SessionToken < ActiveRecord::Base
	extend Utility

#   -------------

	validates_presence_of :token

#   -------------

	belongs_to :user
	belongs_to :client
	belongs_to :partner, polymorphic: true

#   -------------

	def click
		self.increment!(:count)
	end

	def self.app_authenticate(token)
		st_obj = where(token: token).includes(:user).last
		if st_obj
			st_obj.click
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

	def self.create_token_obj(user, platform=nil, pn_token=nil, client=nil, partner=nil)
		Resque.enqueue(CreatePnTokenJob, user.id, pn_token, platform) if pn_token
		client_id = client.id if client
		partner_id = partner.id if partner
		partner_type = partner.class.to_s if partner
		Resque.enqueue(ClientContentUsersJob, client_id, user.id) if client
		SessionToken.create(user_id: user.id,
							token: create_session_token,
							platform: platform,
							push: pn_token,
							client_id: client_id,
							partner_id: partner_id,
							partner_type: partner_type,
							count: 1)
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

