module UrbanAirshipWrap

    def ua_push payload, obj_id, obj_type="Gift"
        resp = Urbanairship.push(payload)
        puts "APNS push sent via ALIAS! #{resp}"
        Ditto.send_push_create(resp, obj_id, obj_type)
    end

    def ua_register pn_token, user_alias, user_id, platform=nil
        platform = platform.present? ? platform.to_sym : :ios
        resp = Urbanairship.register_device(pn_token, :alias => user_alias, :provider =>  platform)
        puts "UA response --- >  #{resp}"
        Ditto.register_push_create(resp, user_id)
    end

    def ua_unregister pn_token, user_id
        resp = Urbanairship.unregister_device(pn_token)
        puts "UA response --- >  #{resp}"
        Ditto.unregister_push_create(resp, user_id)
    end

    def ua_device_tokens
        tokens = Urbanairship.device_tokens_with_limiting
        puts "UA response --- >  #{tokens}"
        return tokens
    end

    def format_payload(alert, user, alert_type, badge=nil)
        badge = badge.present? ? badge : Gift.get_notifications(user)
        {
            :aliases => [user.ua_alias],
            :aps => {
                :alert => alert,
                :badge => badge,
                :sound => 'pn.wav'
            },
            :alert_type => alert_type,
            :android => {
                :alert => alert
            }
        }
    end


end