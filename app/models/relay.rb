class Relay < ActiveRecord::Base
	attr_accessible :gift_id, :giver_id, :name, :provider_id, :receiver_id, :status

	belongs_to :gift
	belongs_to :provider
	belongs_to :giver ,    class_name: "User"
	belongs_to :receiver , class_name: "User"

	validates_presence_of :provider_id, :status, :name 
	validates :gift_id , presence: true, uniqueness: true

	def self.createRelayFromGift(gift)
		relay 			  = Relay.new
		relay.gift_id     = gift.id
		relay.giver_id    = gift.giver_id
		relay.receiver_id = gift.receiver_id if gift.receiver_id
		relay.provider_id = gift.provider_id
		relay.status      = gift.status
		relay.name        = "new_gift"
		relay.save
		return relay
	end

	def self.updateRelayFromGift(gift)
		relay = Relay.find_by_gift_id(gift.id)
		if relay
			update_hash = {:status => gift.status}
			if !relay.receiver_id
				update_hash["receiver_id"] = gift.receiver_id
			end
			relay.update_attributes(update_hash)	
		else
				#  OLD DATA
			relay = Relay.createRelayFromGift(gift)
		end
	end




end
