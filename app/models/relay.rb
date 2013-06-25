require 'apns'

class Relay < ActiveRecord::Base
	include APNS

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
			# get the user tokens from the pn_token db
		receiver  	= gift.receiver
		payload 	= self.format_payload(gift, receiver)
		puts "SENDING PUSH NOTE for GIFT ID = #{gift.id}"
		resp  		= Urbanairship.push(payload)
		puts "APNS push sent via ALIAS! #{resp}"

		# IF ALIAS system fails

		# pn_tokens = receiver.pn_token
		# puts "SENDING PUSH NOTE for GIFT ID = #{gift.id} && receiver = #{receiver.id}"
		# puts "PN_TOKENS = #{pn_tokens.to_s}"
		# if pn_tokens.count > 0
		# 	# send push notification HERE
		# 	payload = self.format_token_payload(gift,receiver, pn_tokens)
		# 	resp  	= Urbanairship.push(payload)
		# 	puts "APNS push sent via TOKEN! #{resp}"
		# end
	end

private

	def self.format_payload(gift, receiver)
		# gift_array 	= Gift.get_gifts(receiver)
		# badge 		= gift_array.size
		{ :aliases => [receiver.ua_alias],
			:aps => { :alert => "#{gift.giver_name} sent you a gift at #{gift.provider_name}!", :badge => "+1", :sound => 'default' },
			:alert_type => 1
		}
	end

	# def self.format_token_payload(gift,receiver, pn_tokens)
	# 	gift_array 	= Gift.get_gifts(receiver)
	# 	badge 		= gift_array.size
	# 	{ :device_tokens => pn_tokens,
	# 		:aps => { :alert => "#{gift.giver_name} sent you a gift at #{gift.provider_name}", :badge => badge, :sound => 'default' }
	# 	}
	# end
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

