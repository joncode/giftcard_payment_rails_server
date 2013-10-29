module Cron

    def send_pn_tokens
        us = User.where("created_at > ?",  1.week.ago)

        us.each do |user|
            pnts = user.pn_tokens
            if pnts.count > 1
                pnts.each do |pnt|
                    send_to_UA(pnt, user)
                end
            elsif pnts.count == 1
                send_to_UA(pnts.first, user)
            end
        end
    end

    def send_to_UA pnt, user
        user_alias  = user.ua_alias
        resp = Urbanairship.register_device(pnt.pn_token, :alias => user_alias )
        puts "#{resp}"
    end

end