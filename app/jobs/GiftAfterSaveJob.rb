class GiftAfterSaveJob

	@queue = :after_save

    def self.perform gift_or_gift_id, client_id=1
    	puts "\n REDISWRAP gift #{gift_or_gift_id} is in GiftAfterSaveJob.rb\n"

    	if gift_or_gift_id.class == Gift
    		gift = gift_or_gift_id
    	else
    		gift = Gift.includes(:giver).includes(:receiver).find(gift_or_gift_id)
    	end
        [gift.giver, gift.receiver].each do |person|
            if person.kind_of?(User)
                client_id = gift.client_id || client_id
                gifts = Gift.get_user_activity_in_client(person, client_id)
                puts "REDISWRAP setting cache for #{client_id} - #{gift.id}"
                RedisWrap.set_user_gifts(client_id, person.id, gifts.serialize_objs(:web))
                if gift.giver_id == gift.receiver_id
                    break
                end
            end
        end

	end


end