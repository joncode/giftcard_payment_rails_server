require 'json'
require 'urban_airship_wrap'

module Urbanairship
    module ClassMethods
        def device_tokens
            do_request(:get, "/api/device_tokens/", :authenticate_with => :master_secret)
        end

        def device_tokens_with_limiting
            response = do_request(:get, "/api/device_tokens/", :authenticate_with => :master_secret)
            Ditto.tokens_push_create(response)
            ua_count_of_total_tokens = response['device_tokens_count']
            dts      = response["device_tokens"]
            while response["next_page"].present?
                puts "UA limiting call - GET - #{response['next_page']}"
                next_path     = response["next_page"].split('.com')[1]
                response      = do_request(:get, next_path, :authenticate_with => :master_secret)
                dts = dts + response["device_tokens"]
            end
            puts "Total tokens received = #{dts.count} -----------------"
            puts "Total tokens with Urbanairship ======  #{ua_count_of_total_tokens}"
            dts
        end

        def log_request_and_response(request, response, time)
            return if logger.nil?

            time = (time * 1000).to_i
            http_method = request.class.to_s.split('::')[-1]
            new_body = response.body.inspect
            short_body = truncate(new_body ,length: 600).gsub('&quot;', "\'")
            logger.info "Urbanairship (#{time}ms): [#{http_method} #{request.path}, #{request.body}], [#{response.code}, #{short_body}]"
            logger.flush if logger.respond_to?(:flush)
        end
    end
end

module Cron
    include UrbanAirshipWrap

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
            else
                send_to_UA(pnt)
                incorrect += 1
            end
        end
        puts "Register missing PnTokens"
        puts "Total UA pn_tokens      = #{ua_key_hsh.keys.count}"
        puts "Total db pn_tokens      = #{total}"
        puts "UA has correct tokens   = #{count}"
        puts "missing tokens are      = #{incorrect}"
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
                    else
                        incorrect += 1
                        puts "PnToken #{pnt.id} is #{ua_alias} -- should be #{pnt_alias} "
                        ua_unregister(pnt.pn_token, pnt.user_id)
                        send_to_UA(pnt)
                    end
                end
            end
        end
        puts "check and update Aliases"
        puts "Total UA pn_tokens      = #{ua_key_hsh.keys.count}"
        puts "Total db pn_tokens      = #{total}"
        puts "UA has correct tokens   = #{count}"
        puts "Incorrect aliases are   = #{incorrect}"
    end

    def test_ua
        get_and_sort_ua_tokens
        nil
    end

private

    def get_and_sort_ua_tokens
        ua_tokens   = ua_device_tokens

        ua_key_hsh = {}
        ua_tokens.each do |uat|
            key = uat["device_token"].downcase
            ua_key_hsh[key] = uat
        end
        ua_key_hsh
    end

    def send_to_UA pnt
        ua_register(pnt.pn_token, pnt.ua_alias, pnt.user_id, pnt.platform)
    end

end














