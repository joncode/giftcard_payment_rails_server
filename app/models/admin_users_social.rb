class AdminUsersSocial < ActiveRecord::Base
	self.table_name = "admin_users_socials"

#   -------------

	validates :social_id, :uniqueness => { scope: :admin_user_id }

#   -------------

	belongs_to :admin_user
	belongs_to :social


end
