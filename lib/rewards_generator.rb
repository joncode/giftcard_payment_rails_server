module RewardsGenerator

    def self.make_gifts campaign_items_ary
        puts "------------- Promo Rewards Generator  -----------------"
        items = campaign_items_ary
        users = self.get_users
        self.create_gifts(items, users)
    end

private

    def self.create_gifts(items, users)
        ary = self.make_reservable_items(items)
        users.each do |user|
            choice_index  = rand(ary.length)
            campaign_item = ary.slice!(choice_index)
            if campaign_item
                hsh = { "receiver_id" => user.id, "receiver_name" => user.name, "payable_id" => campaign_item.id }
                gift = GiftCampaign.create(hsh)
                if gift.id.nil?
                    puts "Errors = #{gift.errors.messages}"
                else
                    puts "gift ID = #{gift.id}"
                end
            else
                puts "finished campaign items"
                break
            end
        end
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


