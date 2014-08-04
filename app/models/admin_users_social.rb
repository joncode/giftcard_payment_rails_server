class AdminUsersSocial < ActiveRecord::Base
	self.table_name = "admin_users_socials"

	belongs_to :admin_user
	belongs_to :social

	validates :social_id, :uniqueness => { scope: :admin_user_id }

end
