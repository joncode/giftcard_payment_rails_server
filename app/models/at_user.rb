class AtUser < AdminUser
	has_many :at_users_socials
	has_many :socials, through: :at_users_socials

end