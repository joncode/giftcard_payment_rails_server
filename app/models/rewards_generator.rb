module RewardsGenerator

    def self.make_gifts item_ids_ary
        puts "------------- Promo Rewards Generator  -----------------"
        items = CampaignItem.find(item_ids_ary)
        users = self.get_users
        status_hash = self.create_gifts(items, users)
        return status_hash
    end

private

    def self.create_gifts(items, users)
    	created_gifts_count = 0
    	status =  "Gift Creation Successful"
        ary = self.make_reservable_items(items)
        users.each do |user|
            choice_index  = rand(ary.length)
            campaign_item = ary.slice!(choice_index)
            if campaign_item
                hsh = { "receiver_id" => user.id, "receiver_name" => user.name, "payable_id" => campaign_item.id }
                gift = GiftCampaign.create(hsh)
                if gift.id.nil?
                    fail_message = "#{gift.errors.full_messages}"
                    puts fail_message
                    status = fail_message
                    break
                else
                    puts "gift ID = #{gift.id}"
                    created_gifts_count += 1
                end
            else
                fail_message = "Campaign items reserve was used up"
                puts fail_message
                status = fail_message
                break
            end
        end
        return { status: status, created_gifts_count: created_gifts_count }
    end

    def self.campaign_items_ary
        ci1 = CampaignItem.where(textword: 'a').last
        ci2 = CampaignItem.where(textword: 'b').last
        return [ci1, ci2].compact
    end

    def self.get_users
        User.where(active: true).order('created_at DESC')
    end

    def self.make_reservable_items live_items
        reservable_items = []
        live_items.each do |item|
            item.reserve.times do
                reservable_items << item
            end
        end
        reservable_items
    end

end


