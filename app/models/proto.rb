class Proto < ActiveRecord::Base
	include GenericPayableDucktype

	has_many   :proto_joins
	has_many   :users, 		through: :proto_joins, source: :receivable, source_type: 'User'
	has_many   :socials, 	through: :proto_joins, source: :receivable, source_type: 'Social'
	belongs_to :receivable, polymorphic: true
	belongs_to :provider
	belongs_to :giver,      polymorphic: :true
	#has_many   :receivables, through: :proto_joins, source: :receivable, source_type: "Receivable"

	validates_presence_of :cat, :shoppingCart, :expires_at, :giver_id, :giver_type, :giver_name, :provider_id, :provider_name

	def receivables
			# returns receivables (Users or Socials)
		self.users + self.socials
		ProtoJoin.where(proto_id: self.id).map{|obj| obj.receivable }
	end

	def giftables
			# returns proto_join objects
		ProtoJoin.where(proto_id: self.id, gift_id: nil)
	end

end
