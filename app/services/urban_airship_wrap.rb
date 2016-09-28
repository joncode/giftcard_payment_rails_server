module UrbanAirshipWrap

    def send_push(user, alert, gift_id)
        puts "SENDING PUSH NOTE for GIFT ID = #{gift_id} | PUSH_RECEIVER ID = #{user.id} | #{alert}"
        pnts = user.pn_tokens
        resp = []
        googe_push_tokens = []
        pnts.each do |pn_token_obj|
            begin
                if pn_token_obj.platform == 'ios'
                    r = send_push_with_apns(pn_token_obj, alert)
                    resp << r
                elsif pn_token_obj.platform == 'android'
                    # is the token for the new APP ?
                    if pn_token_obj.pn_token.length > 40
                        # new google push
                        googe_push_tokens << pn_token_obj
                    else
                        pn_token_obj.destroy
                        # r = send_push_with_urban_airship(pn_token_obj, alert)
                        # puts "500 Internal - PUSH NO PLATFORM |#{pn_token_obj.id}| - #{r.inspect}"
                    end
                end
            rescue
                puts "500 Internal PUSH FAILED - #{user.id} - #{pn_token_obj.id}"
            end
        end

        if googe_push_tokens.count > 0

            if alert.to_s.match(/has been delivered/)
                hsh = { message: alert,
                        title: 'ItsOnMe Gift Delivered!',
                        args: { gift_id: gift_id }
                    }
            elsif alert.to_s.match(/opened your gift/)
                hsh = { message: alert,
                        title: 'ItsOnMe Gift Opened!',
                        args: { gift_id: gift_id }
                    }
            elsif alert.to_s.match(/got the app/)
                hsh = { message: alert,
                        title: 'Thank You!',
                        args: { gift_id: gift_id }
                    }
            else
                hsh = { message: alert,
                        title: 'New ItsOnMe Gift!',
                        action: 'VIEW_GIFT',
                        args: { gift_id: gift_id }
                    }
            end

            r = OpsGooglePush.send_push(googe_push_tokens, hsh)
            puts "PUSH SUCCEEDED |#{googe_push_tokens.map(&:id)}| - #{r.inspect}"
            resp << r
        end

        puts "APNS push sent via TOKENS! #{resp.inspect}"
        Ditto.send_push_create(resp[0], gift_id, 'Gift')
    end

    def send_push_with_apns(pnt, alert)
        n = APNS::Notification.new(pnt.pn_token, alert)
        APNS.send_notifications([n])
    end

    def send_push_with_urban_airship(pn_token_obj, alert)
        push = UA_CLIENT.create_push
        if pn_token_obj.platform == 'ios'
            push.audience = UA.device_token(pn_token_obj.pn_token)
        else
            push.audience = UA.apid(pn_token_obj.pn_token)
        end
        push.notification = UA.notification(alert: alert)
        push.device_types = UA.all
        push.send_push
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
