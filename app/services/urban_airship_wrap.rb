module UrbanAirshipWrap

    def ua_push payload, obj_id, obj_type="Gift"
        push = Airship.create_push
        push.audience = payload[:audience]
        push.notification = UA.notification(alert: payload[:aps][:alert])
        push.device_types = UA.all
        resp = push.send_push
        puts "APNS push sent via ALIAS! #{resp}"
        Ditto.send_push_create(resp, obj_id, obj_type)
    end

    def ua_register pn_token, user_alias, user_id, platform=nil
        platform = platform.present? ? platform : 'ios'
        resp = Airship.register_device(pn_token, :alias => user_alias, :provider =>  platform.to_sym)
        puts "UA response --- >  #{resp}"
        Ditto.register_push_create(resp, user_id)
    end

    def ua_unregister pn_token, user_id
        resp = Airship.unregister_device(pn_token)
        puts "UA response --- >  #{resp}"
        Ditto.unregister_push_create(resp, user_id)
    end

    def ua_device_tokens
        tokens = Airship.device_tokens_with_limiting
        #puts "UA response --- >  #{tokens}"
        return tokens
    end

    def format_payload(alert, user, alert_type, badge=nil)
        badge = badge.present? ? badge : Gift.get_notifications(user)
        {
            :audience => {
                :alias => user.ua_alias,
            },
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
