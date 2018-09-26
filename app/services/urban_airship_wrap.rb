module UrbanAirshipWrap

    def send_push(user, alert, gift_id=nil, redemption_id=nil)
        args = []
        args << "gift:#{gift_id}"              if gift_id.present?
        args << "redemption:#{redemption_id}"  if redemption_id.present?
        args << "user:#{user.id}"              # Last to make grepping easier
        _signature = "[module UrbanAirshipWrap :: send_push(#{args.join(', ')})]"

        puts "#{_signature}  Sending push notification"
        puts " | alert:    #{alert}"

        target_id = target_type = nil
        target_id = gift_id || redemption_id
        target_type = 'Gift' if gift_id
        target_type = 'Redemption' if redemption_id
        pnts = user.pn_tokens
        resp = []
        googe_push_tokens = []
        pnts.each do |pn_token_obj|
            begin
                puts " | platform: #{pn_token_obj.platform.inspect rescue '(unknown)'}"
                if pn_token_obj.platform == 'ios'
                    r = OpsPushApple.send_push(pn_token_obj, alert, target_id)
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
            rescue => e
                puts "#{_signature}  Error: #{e.inspect}"
                puts " | pn_token_obj_id: #{pn_token_obj}.id"
            end
        end

        if googe_push_tokens.count > 0

            r = OpsPushGoogle.send_push(googe_push_tokens, alert, target_id)
            puts "#{_signature}  Push succeeded!"
            puts " | Google token IDs: #{googe_push_tokens.map(&:id)}"
            puts " | Response: #{r.inspect} "
            resp << r
        end

        puts "#{_signature}  Push sent via TOKENS! #{resp.inspect}"
        Ditto.send_push_create(resp[0], target_id, target_type)
    end


#------------------------------    RETIRED


    # def format_payload(alert, user, alert_type, badge=nil)
    #     badge = badge.present? ? badge : Gift.get_notifications(user)
    #     {
    #         :audience => {
    #             :alias => user.ua_alias,
    #         },
    #         :aps => {
    #             :alert => alert,
    #             :badge => badge,
    #             :sound => 'pn.wav'
    #         },
    #         :alert_type => alert_type,
    #         :android => {
    #             :alert => alert
    #         }
    #     }
    # end

    # def send_push_with_urban_airship(pn_token_obj, alert)
    #     push = UA_CLIENT.create_push
    #     if pn_token_obj.platform == 'ios'
    #         push.audience = UA.device_token(pn_token_obj.pn_token)
    #     else
    #         push.audience = UA.apid(pn_token_obj.pn_token)
    #     end
    #     push.notification = UA.notification(alert: alert)
    #     push.device_types = UA.all
    #     push.send_push
    # end

    # def ua_register pn_token, user_alias, user_id, platform=nil
    #     platform = platform.present? ? platform : 'ios'
    #     resp = UA_CLIENT.register_device(pn_token, :alias => user_alias, :provider =>  platform.to_sym)
    #     puts "UA response --- >  #{resp.inspect}"
    #     Ditto.register_push_create(resp, user_id)
    # end

    # def ua_unregister pn_token, user_id
    #     resp = UA_CLIENT.unregister_device(pn_token)
    #     puts "UA response --- >  #{resp.inspect}"
    #     Ditto.unregister_push_create(resp, user_id)
    # end

    # def ua_device_tokens
    #     tokens = UA_CLIENT.device_tokens_with_limiting
    #     #puts "UA response --- >  #{tokens}"
    #     return tokens
    # end
end
