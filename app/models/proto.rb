class Proto < ActiveRecord::Base
    include ShoppingCartHelper

#   -------------

	validates_presence_of :cat, :expires_at, :giver_id, :giver_type, :giver_name, :merchant_id, :provider_name

#   -------------

	before_save :set_value
	before_save :set_cost

#   -------------

	#has_many   :receivables, through: :proto_joins, source: :receivable, source_type: "Receivable"
	has_many   :proto_joins
	has_many   :users, 		through: :proto_joins, source: :receivable, source_type: 'User'
	has_many   :socials, 	through: :proto_joins, source: :receivable, source_type: 'Social'
	has_many   :gifts,      through: :proto_joins
	belongs_to :receivable, polymorphic: true
	belongs_to :provider
  	belongs_to :merchant
	belongs_to :giver,      polymorphic: :true

	def receivables
			# returns receivables (Users or Socials)
		self.users + self.socials
	end

	def giftables
			# returns proto_join objects
		ProtoJoin.where(proto_id: self.id, gift_id: nil)
	end

    def ccy
    	"USD"
    end

#   -------------

	def update_contacts new_amount=1
        self.increment!(:contacts, new_amount)
	end

	def update_processed new_amount=1
        self.increment!(:processed, new_amount)
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
# == Schema Information
#
# Table name: protos
#
#  id            :integer         not null, primary key
#  message       :text
#  detail        :text
#  shoppingCart  :text
#  value         :string(255)
#  cost          :string(255)
#  expires_at    :datetime
#  created_at    :datetime
#  updated_at    :datetime
#  giver_id      :integer
#  giver_type    :string(255)
#  giver_name    :string(255)
#  merchant_id   :integer
#  provider_name :string(255)
#  cat           :integer
#  contacts      :integer         default(0)
#  processed     :integer         default(0)
#

