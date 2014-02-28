class Redeem < ActiveRecord::Base

	belongs_to      :gift
	has_one         :giver,     :through => :gift
	has_one         :receiver,  :through => :gift
	has_one         :provider,  :through => :gift
	has_one         :order

	before_create :create_redeem_code
	after_create  :add_redeem_to_gift

	validates :gift_id , presence: true, uniqueness: true

	def self.find_or_create_with_gift(gift)
		unless redeem = Redeem.find_by(gift_id: gift.id)
				# redeem must be created
			redeem = Redeem.init_with_gift(gift)
		end
		return redeem
	end

	def self.init_with_gift(gift)
		Redeem.create(gift_id: gift.id)
	end

private

	def create_redeem_code
		self.redeem_code = "%04d" % rand(10000)
	end

	def add_redeem_to_gift
		self.gift.update(status: 'notified')
	end
end
# == Schema Information
#
# Table name: redeems
#
#  id          :integer         not null, primary key
#  gift_id     :integer
#  redeem_code :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

