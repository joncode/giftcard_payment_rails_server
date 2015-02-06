class Affiliate < ActiveRecord::Base

	has_many :affiliations
	has_many :merchants, through: :affiliations, source: :target, source_type: 'Merchant'
	has_many :users, 	 through: :affiliations, source: :target, source_type: 'User'
	has_many :payments,     as: :partner
	has_many :registers,    as: :partner
	has_many :landing_pages
	has_many :affiliate_gifts
	has_many :gifts, through: :affiliate_gifts

	def create_affiliation(target_type)
		if target_type == "User"
			self.total_users += 1
		elsif target_type == "Merchant"
			self.total_merchants += 1
		else
			# unknown target type
		end
	end

	def link_gift_created amount, gift
		self.payout_links	+= amount
		self.purchase_links	+= 1
		self.value_links	+= gift.value_in_cents
	end

	def user_gift_created amount, gift
		self.payout_users	+= amount
		self.purchase_users	+= 1
		self.value_users	+= gift.value_in_cents
	end

	def merchant_gift_created amount, gift
		self.payout_merchants	+= amount
		self.purchase_merchants	+= 1
		self.value_merchants	+= gift.value_in_cents
	end

end
