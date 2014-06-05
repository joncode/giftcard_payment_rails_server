module RewardsGenerator

    def self.make_gifts item_ids_ary
        puts "------------- Promo Rewards Generator  -----------------"
        items = CampaignItem.find(item_ids_ary)
        user_array = self.get_user_array
        status_hash = self.create_gifts(items, users)
        return status_hash
    end

private

    def self.create_gifts(items, users)
    	created_gifts_count = 0
    	status  =  "Gift Creation Successful"
        ary     = self.make_reservable_item_ids(items)
        users.each do |user|
            choice_index  = rand(ary.length)
            campaign_item = ary.slice!(choice_index)
            if campaign_item
                hsh  = { "receiver_id" => user[0], "receiver_name" => self.name(user[1], user[2]), "payable_id" => campaign_item }
                gift = GiftCampaign.create(hsh)
                if gift.id.nil?
                    puts "RewardsGenerator - Errors = #{gift.errors.messages}"
                else
                    puts "RewardsGenerator - gift ID = #{gift.id}"
                    created_gifts_count += 1
                end
            else
            	fail_message = "RewardsGenerator - Campaign items reserve was used up"
                puts fail_message
                status = fail_message
                break
            end
        end
        return { status: status, created_gifts_count: created_gifts_count }
    end

    def self.get_user_array
       User.where(active: true).pluck(:id, :first_name, :last_name)
    end

    def self.make_reservable_item_ids live_items
        reservable_items = []
        live_items.each do |item|
            item.reserve.times do
                reservable_items << item.id
            end
        end
        reservable_items
    end

    def self.name(first_name, last_name)
        if last_name.blank?
            "#{first_name}"
        else
            "#{first_name} #{last_name}"
        end
    end

end


