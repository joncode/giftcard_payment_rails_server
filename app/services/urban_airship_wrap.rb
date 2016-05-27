module UrbanAirshipWrap

    def send_push(user, alert, gift_id)
        puts "SENDING PUSH NOTE for GIFT ID = #{gift_id} | PUSH_RECEIVER ID = #{user.id} | #{alert}"
        pnts = user.pn_tokens
        resp = []
        pnts.each do |pn_token_obj|
            begin
                push = UA_CLIENT.create_push
                if pn_token_obj.platform == 'ios'
                    push.audience = UA.device_token(pn_token_obj.pn_token)
                elsif pn_token_obj.platform == 'android'
                    push.audience = UA.apid(pn_token_obj.pn_token)
                end
                push.notification = UA.notification(alert: alert)
                push.device_types = UA.all
                r = push.send_push
                puts "PUSH TOKEN |#{pn_token_obj.id}| - #{r.inspect}"
                resp << r
            rescue
                puts "500 Internal PUSH FAILED - #{user.id} - #{pn_token_obj.id}"
            end
        end

        puts "APNS push sent via TOKENS! #{resp.inspect}"
        Ditto.send_push_create(resp[0], gift_id, 'Gift')
    end

    def ua_register pn_token, user_alias, user_id, platform=nil
        platform = platform.present? ? platform : 'ios'
        resp = UA_CLIENT.register_device(pn_token, :alias => user_alias, :provider =>  platform.to_sym)
        puts "UA response --- >  #{resp.inspect}"
        Ditto.register_push_create(resp, user_id)
    end

    def ua_unregister pn_token, user_id
        resp = UA_CLIENT.unregister_device(pn_token)
        puts "UA response --- >  #{resp.inspect}"
        Ditto.unregister_push_create(resp, user_id)
    end

    def ua_device_tokens
        tokens = UA_CLIENT.device_tokens_with_limiting
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
