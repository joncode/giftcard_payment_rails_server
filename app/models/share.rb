class Share < ActiveRecord::Base

	before_validation :default_user_action

#   -------------

	validates_presence_of :network_id, :user_action

#   -------------




private


	def default_user_action
		if self.user_action.nil?
			self.user_action = 'share'
		end
	end


end