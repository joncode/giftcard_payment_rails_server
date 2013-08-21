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

end
