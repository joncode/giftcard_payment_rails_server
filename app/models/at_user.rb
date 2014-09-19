class AtUser < Admtmodel
    self.table_name = "users"

	has_many :at_users_socials

	def name
		if self.last_name.blank?
			"#{self.first_name}"
		else
			"#{self.first_name} #{self.last_name}"
		end
	end
	
end