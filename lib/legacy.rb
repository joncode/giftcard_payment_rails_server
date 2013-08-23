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

end
