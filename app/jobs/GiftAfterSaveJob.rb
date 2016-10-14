class GiftAfterSaveJob

	@queue = :after_save

    def self.perform gift_or_gift_id, client_id=1
    	puts "\n REDISWRAP gift #{gift_or_gift_id}|#{client_id} is in GiftAfterSaveJob.rb\n"
        return
    	if gift_or_gift_id.class == Gift
    		gift = gift_or_gift_id
    	else
    		gift = Gift.unscoped.includes(:giver).includes(:receiver).find(gift_or_gift_id)
    	end
        [gift.giver, gift.receiver].each do |person|
            if person.kind_of?(User)
                client_id = gift.client_id if gift.client_id
                gifts = Gift.get_user_activity_in_client(person, client_id)
                RedisWrap.clear_all_user_gifts(person.id)
                if client_id.nil?
                    puts "GiftAfterSaveJob - nil client ID for gift #{gift.id} #{gift.client_id}"
                else
                    puts "REDISWRAP setting cache for #{client_id} - #{gift.id}"
                    RedisWrap.set_user_gifts(client_id, person.id, gifts.serialize_objs(:web))
                end
                if gift.giver_id == gift.receiver_id
                    break
                end
            end
        end

	end

end