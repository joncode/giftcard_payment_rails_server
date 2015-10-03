class GiftAfterSaveJob

	@queue = :after_save

    def self.perform gift_or_gift_id
    	puts "\n gift #{gift_or_gift_id} is being GiftOpenedEvent.rb\n"

    	if gift_or_gift_id.class == Gift
    		gift = gift_or_gift_id
    	else
    		gift = Gift.includes(:giver).includes(:receiver).find(gift_or_gift_id)
    	end
        [gift.giver, gift.receiver].each do |person|
            gifts = Gift.get_user_activity_in_client(person, gift.client_id)
            RedisWrap.set_user_gifts(gift.client_id, person.id, gifts.serialize_objs(:web))
        end

	end


end