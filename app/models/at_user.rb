class AtUser < ActiveRecord::Base

	has_many :at_users_socials

	def name
		if self.last_name.blank?
			"#{self.first_name}"
		else
			"#{self.first_name} #{self.last_name}"
		end
	end

    def giver
        AdminGiver.find(self.id)
    end

    def get_photo
		if self.photo
			self.photo
		else
            nil
		end
	end
end