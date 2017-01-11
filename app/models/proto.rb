class Proto < ActiveRecord::Base
    include ShoppingCartHelper
    include MoneyHelper

#   -------------

    auto_strip_attributes :message, :detail, :title, :desc
    auto_strip_attributes :promo_code, downcase: true, letter_numbers: true

#   -------------

	validates_presence_of :cat, :giver_id, :giver_type, :giver_name, :merchant_id, :provider_name

#   -------------

	before_save :set_value
	before_save :set_value_cents
	before_save :set_cost
	before_save :set_cost_cents

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

#   -------------

	def gifting?
		return false unless self.active
		return false unless self.live
		return false if (!self.expires_at.nil? && (DateTime.now.utc > self.expires_at))
		return false if (!self.maximum.nil? && (self.processed >= self.maximum))
		return true
	end

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

	def days= days_int
		@days = days_int
		self.expires_in = days_int.days.to_i
	end

	def days
		return @days if @days
		if @days.nil? && self.expires_in.nil?
			return nil
		else
			self.expires_in / 24 / 60 / 60
		end
	end

#   -------------

	def update_contacts new_amount=1
        self.increment!(:contacts, new_amount)
	end

	def update_processed new_amount=1
        self.increment!(:processed, new_amount)
	end

#   -------------

    def value_cents
    	super || set_value_cents
    end

    def cost_cents
    	super || set_cost_cents
    end


#   -------------


	def socials_complete?
		self.socials.count > 0
	end

	def details_complete?
		self.expires_at.present? || self.expires_in.present?
	end

	def items_complete?
		self.shoppingCart.present?
	end

	def self.destroy_incomplete_protos
		dt = 7.days.ago
		Proto.where( shoppingCart: nil).where('created_at < ?', dt).find_each do |proto|
			puts "Destroying proto #{proto.id} - shoppingCart"
			proto.destroy
		end
		Proto.where(expires_at: nil, expires_in: nil).where('created_at < ?', dt).find_each do |proto|
			puts "Destroying proto #{proto.id} - expiration"
			proto.destroy
		end
	end

private

	def set_value_cents
		self.value_cents = currency_to_cents(self.value)
	end

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

	def set_cost_cents
		self.cost_cents = currency_to_cents(self.cost)
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

