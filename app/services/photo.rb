module Photo

    def shorten_url_for_provider_ary providers_array
        providers_array.each do |prov|
            short_photo_url = short_photo_url prov["photo"]
            prov["photo"]   = short_photo_url
        end
    end

    def shorten_url_for_brand_ary brands_array
        brands_array.each do |brand|
            short_photo_url = short_photo_url brand["photo"]
            brand["photo"]  = short_photo_url
        end
    end

    def short_photo_url photo_url
        url_ary         = photo_url.split('upload/')
        shorten_url     = url_ary[1]

        identifier, tag = shorten_url.split('.')

        new_photo_ary   = ['d', identifier , 'j']
        if photo_url.match 'htaaxtzcv'
            new_photo_ary[0] = 'h'
        end

        if !tag.match('jpg')
            new_photo_ary[2] = tag.match('png') ? 'p' : tag
        end

        new_photo_ary.join("|")
    end

end