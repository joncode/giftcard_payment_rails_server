class Relay < ActiveRecord::Base
	attr_accessible :gift_id, :giver_id, :name, :provider_id, :receiver_id, :status

	belongs_to :gift
	belongs_to :provider
	belongs_to :giver ,    class_name: "User"
	belongs_to :receiver , class_name: "User"

	validates_presence_of :provider_id, :status, :name
	validates :gift_id , presence: true, uniqueness: true

	def self.createRelayFromGift(gift)
		# relay 			  = Relay.new
		# relay.gift_id     = gift.id
		# relay.giver_id    = gift.giver_id
		# relay.receiver_id = gift.receiver_id if gift.receiver_id
		# relay.provider_id = gift.provider_id
		# relay.status      = gift.status
		# relay.name        = "new_gift"
		# relay.save
		# return relay
	end

	def self.updateRelayFromGift(gift)
		# relay = Relay.find_by_gift_id(gift.id)
		# if relay
		# 	update_hash = {:status => gift.status}
		# 	if !relay.receiver_id
		# 		update_hash["receiver_id"] = gift.receiver_id
		# 	end
		# 	relay.update_attributes(update_hash)
		# else
		# 		#  OLD DATA
		# 	relay = Relay.createRelayFromGift(gift)
		# end
	end

	def self.send_push_notification(gift)
		# 4. get the user tokens from the pn_token db
		receiver  = gift.receiver
		pn_tokens = receiver.pn_token
		puts "SENDING PUSH NOTE for GIFT ID = #{gift.id} && receiver = #{receiver.id}"
		puts "PN_TOKENS = #{pn_tokens.to_s}"
		if pn_tokens.count > 0
			# send push notification HERE
			payload = format_payload(gift)
			send_to_apns(payload, pn_tokens)
		end
	end

private

	def format_payload(gift)
		"This will be the payload"
	end

	def send_to_apns(payload, tokens)
		puts "Send this to APNS payload = #{payload}, pn_token = #{tokens.to_s}"
	end

end
# == Schema Information
#
# Table name: relays
#
#  id          :integer         not null, primary key
#  gift_id     :integer
#  giver_id    :integer
#  provider_id :integer
#  receiver_id :integer
#  status      :string(255)
#  name        :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

