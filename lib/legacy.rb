module Legacy

    def brand_photo_fix
        b_all = Brand.all
        b_all.each do |brand|
            if brand.photo.present?
                brand.portrait = brand.photo
                brand.photo = nil
                brand.save
            end
            puts brand.inspect
        end
    end

    def delete_dev_gifts

    end

    def deactive p_ary
        p_ary.each do |p|
            prov = Provider.find p
            prov.update_attribute(:active, false)
        end
    end

    def delete_gifts
        gs = Gift.where(status: 'redeemed')
        gs.each do |gift|
            if gift.sales.count == 0
                gift.destroy
            end
        end
        gs = Gift.all
        gs.each do |g|
            p = g.provider
            if not p.active
                g.destroy
            end
        end
    end

    def update_menu_to_detail menu_string
        menu = JSON.parse menu_string.menu
        menu.each do |section|
            items_ary = section["item"]
            items_ary.each do |item|
                if item.has_key? "description"
                    item["detail"] = item["description"]
                    item.delete("description")
                end
            end
        end
        menu_string.menu = menu.to_json
        if not menu_string.save
            puts "Menu String fail #{menu_string.id}"
        end
    end

end











