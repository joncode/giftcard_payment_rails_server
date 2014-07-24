class Proto < ActiveRecord::Base
    include ShoppingCartHelper

	has_many   :proto_joins
	has_many   :users, 		through: :proto_joins, source: :receivable, source_type: 'User'
	has_many   :socials, 	through: :proto_joins, source: :receivable, source_type: 'Social'
	has_many   :gifts,      through: :proto_joins
	belongs_to :receivable, polymorphic: true
	belongs_to :provider
	belongs_to :giver,      polymorphic: :true
	#has_many   :receivables, through: :proto_joins, source: :receivable, source_type: "Receivable"

	validates_presence_of :cat, :expires_at, :giver_id, :giver_type, :giver_name, :provider_id, :provider_name

	before_save :set_value
	before_save :set_cost

	def receivables
			# returns receivables (Users or Socials)
		self.users + self.socials
	end

	def giftables
			# returns proto_join objects
		ProtoJoin.where(proto_id: self.id, gift_id: nil)
	end

private

	def set_value
		if self.shoppingCart.kind_of?(String)
			self.value = calculate_value(self.shoppingCart)
		end
	end

	def set_cost
		if self.cost.nil?
			self.cost = "0"
		end
	end

end
