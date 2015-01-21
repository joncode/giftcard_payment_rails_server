class Affiliate < ActiveRecord::Base

	has_many :affiliations
	has_many :merchants, through: :affiliations, source: :target, source_type: 'Merchant'
	has_many :users, 	 through: :affiliations, source: :target, source_type: 'User'
	has_many :payments,     as: :partner
	has_many :registers,    as: :partner

	def create_affiliation(target_type)
		if target_type == "User"
			self.total_users += 1
		elsif target_type == "Merchant"
			self.total_merchants += 1
		else
			# unknown target type
		end
	end


end
