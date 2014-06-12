class RewardsGenerator

    class << self

        def make_gifts item_ids_ary
            puts "------------- Promo Rewards Generator  -----------------"
            items           = CampaignItem.find(item_ids_ary)
            users_pluck_ary = get_users_array
            status_hash     = create_gifts(items, users_pluck_ary)
            return status_hash
        end

    private

        def create_gifts(items, users_pluck_ary)
        	created_gifts_count = 0
        	status  =  "Gift Creation Successful"
            puts "\n\n users = #{users_pluck_ary}"

            ary     = make_reservable_item_ids(items)

            users_pluck_ary.each do |user_a|

                choice_index     = rand(ary.length)
                campaign_item_id = ary.slice!(choice_index)

                puts "\n\n here is the ary #{ary} --  here is the choice index #{choice_index}"
                if campaign_item_id
                    hsh  = { "receiver_id" => user_a[0], "receiver_name" => name(user_a[1], user_a[2]), "payable_id" => campaign_item_id }
                    puts "\n here is the hsh = #{hsh}"

                    gift = GiftCampaign.create(hsh)
                    if gift.id.nil?
                        puts "RewardsGenerator - Errors = #{gift.errors.messages}"
                    else
                        puts "RewardsGenerator - gift ID = #{gift.id}"
                        created_gifts_count += 1
                    end
                else
                	status = "RewardsGenerator - Campaign items reserve was used up"
                    puts status
                    break
                end
            end

            return { status: status, created_gifts_count: created_gifts_count }
        end

        def get_users_array
            User.where(active: true).pluck(:id, :first_name, :last_name)
        end

        def make_reservable_item_ids live_items
            reservable_items = []
            live_items.each do |item|
                item.reserve.times do
                    reservable_items << item.id
                end
            end
            reservable_items
        end

        def name(first_name, last_name="")
            if last_name.blank?
                "#{first_name}"
            else
                "#{first_name} #{last_name}"
            end
        end
    end

end


