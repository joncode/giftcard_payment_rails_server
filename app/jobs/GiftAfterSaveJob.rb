class GiftAfterSaveJob

	@queue = :after_save

    def self.perform gift_or_gift_id
    	puts "\n REDISWRAP gift #{gift_or_gift_id} is in GiftAfterSaveJob.rb\n"

    	if gift_or_gift_id.class == Gift
    		gift = gift_or_gift_id
    	else
    		gift = Gift.includes(:giver).includes(:receiver).find(gift_or_gift_id)
    	end
        [gift.giver, gift.receiver].each do |person|
            client_id = gift.client_id || 1
            gifts = Gift.get_user_activity_in_client(person, client_id)
            RedisWrap.set_user_gifts(client_id, person.id, gifts.serialize_objs(:web))
        end

	end


end