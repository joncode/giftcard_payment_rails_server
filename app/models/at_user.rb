class AtUser < Admtmodel
    self.table_name = "users"

	has_many :at_users_socials
	has_many :socials, through: :at_users_socials

end