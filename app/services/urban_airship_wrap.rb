module UrbanAirshipWrap

    def ua_push payload, obj_id, obj_type="Gift"
        resp = Urbanairship.push(payload)
        puts "APNS push sent via ALIAS! #{resp}"
        Ditto.send_push_create(resp, obj_id, obj_type)
    end

    def ua_register pn_token, user_alias, user_id, platform=nil
        platform = platform.present? ? platform.to_sym : nil
        resp = Urbanairship.register_device(pn_token, :alias => user_alias, :provider =>  platform)
        puts "UA response --- >  #{resp}"
        Ditto.register_push_create(resp, user_id)
    end

end