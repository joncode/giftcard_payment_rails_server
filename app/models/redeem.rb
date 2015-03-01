class Redeem < ActiveRecord::Base

	belongs_to      :gift , autosave: true
	has_one         :giver,     :through => :gift
	has_one         :receiver,  :through => :gift
	has_one         :provider,  :through => :gift
	has_one         :order

	validates :gift_id , presence: true, uniqueness: true
	validates :redeem_code, :uniqueness => { scope: :pos_merchant_id }, allow_blank: true, :if => :pos_merchant_id?

	before_create :create_redeem_code
	after_create :add_redeem_to_gift

	def self.find_or_create_with_gift(gift)
		unless redeem = gift.redeem
				# redeem must be created
			redeem = Redeem.init_with_gift(gift)
		end
		return redeem
	end

	def self.init_with_gift(gift)
		provider 		= Provider.unscoped.find(gift.provider_id)
		pos_merchant_id = provider.pos_merchant_id
		Redeem.create(gift_id: gift.id, pos_merchant_id: pos_merchant_id)
	end

	def create_redeem_code
		self.redeem_code = "%04d" % rand(10000)
	end

private

	def add_pos_merchant_id
		if !self.pos_merchant_id?
			if gift_provider = Provider.find(self.gift.provider_id)
				gift_provider.pos_merchant_id
			end
		end
	end

	def self.pos_merchant_id?
		self.pos_merchant_id.present? || (self.pos_merchant_id != 0)
	end

	def add_redeem_to_gift
		self.gift.update(status: 'notified')
	end
end
# == Schema Information
#
# Table name: redeems
#
#  id              :integer         not null, primary key
#  gift_id         :integer
#  redeem_code     :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  pos_merchant_id :integer
#

