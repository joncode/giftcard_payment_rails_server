module Urbanairship
    module ClassMethods
        def device_tokens
            do_request(:get, "/api/device_tokens/", :authenticate_with => :master_secret)
        end
    end
end

module Cron

    def register_all_pn_tokens time_ago=nil
        time_ago ||= 1.week.ago
        us = User.where("created_at > ?",  time_ago)

        us.each do |user|
            pnts = user.pn_tokens
            if pnts.count > 1
                pnts.each do |pnt|
                    send_to_UA(pnt)
                end
            elsif pnts.count == 1
                puts "update #{user.id} | #{user.name}'s pn token"
                send_to_UA(pnts.first)
            end
        end
        nil
    end

    def register_missing_pn_tokens
        ua_key_hsh = get_and_sort_ua_tokens
        pnts = PnToken.unscoped
        count = 0
        incorrect = 0
        total = pnts.count
        pnts.each do |pnt|
            if ua_key_hsh.keys.include? pnt.pn_token
                count += 1
                #puts "match #{count}"
            else
                send_to_UA(pnt)
                incorrect += 1
            end
        end
        puts "Here is the total pn tokens = #{total}"
        puts "UA has correct tokens = #{count}"
        puts "Incorrect tokens are  = #{incorrect}"
    end

    def check_update_aliases
        ua_key_hsh = get_and_sort_ua_tokens
        pnts = PnToken.unscoped
        count = 0
        incorrect = 0
        total = pnts.count
        pnts.unscoped.each do |pnt|
            if ua_key_hsh.keys.include? pnt.pn_token
                ua_hsh    = ua_key_hsh[pnt.pn_token]
                if ua_hsh
                    ua_alias  = ua_hsh["alias"]
                    pnt_alias = pnt.ua_alias
                    if pnt_alias == ua_alias
                        count += 1
                        #puts "match #{count}"
                    else
                        incorrect += 1
                        puts "PnToken #{pnt.id} is #{ua_alias} -- should be #{pnt_alias} "
                        Urbanairship.unregister_device(pnt.pn_token)
                        send_to_UA(pnt)
                    end
                end
            end
        end
        puts "Here is the total pn tokens = #{total}"
        puts "UA has correct tokens = #{count}"
        puts "Incorrect tokens are  = #{incorrect}"
    end

private

    def get_and_sort_ua_tokens
        ua_response = ua_device_tokens
        ua_tokens   = ua_response["device_tokens"]

        ua_key_hsh = {}
        ua_tokens.each do |uat|
            key = uat["device_token"].downcase
            ua_key_hsh[key] = uat
        end
        ua_key_hsh
    end

    def send_to_UA pnt
        resp = Urbanairship.register_device(pnt.pn_token, :alias => pnt.ua_alias )
        puts "Registered UA --- > #{resp}"
    end

    def ua_device_tokens
        Urbanairship.device_tokens
    end

end














