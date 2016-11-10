module GiftScopes
    include RedeemHelper

##### GIFT SCOPES


#   -------------

    def get_purchases_for_affiliate affiliate_id, start_date, end_date
        query = "SELECT g.* FROM gifts g, merchants m, affiliates a \
WHERE m.affiliate_id = a.id AND g.merchant_id = m.id AND g.cat = 300 \
AND a.id = #{affiliate_id} AND (g.status NOT IN ('cancel', 'expired')) AND g.active = 't' \
AND (g.created_at >= '#{start_date}' AND g.created_at < '#{end_date}')"
        Gift.find_by_sql(query)
    end

    def pending_redeems_for merchant
        gifts = where(merchant_id: merchant.id, status: ['notified', 'redeemed']).where('new_token_at > ?', reset_time)
        notified_gifts = gifts.where(status: 'notified').order("created_at DESC")
        redeemed_gifts = gifts.where(status: 'redeemed').order("redeemed_at DESC")
        notified_gifts + redeemed_gifts
    end

    def find_gift_for_mt_user_and_code(mt_user_id, code)
        query = "SELECT g.* FROM gifts g, invites i , merchants m \
WHERE i.mt_user_id = #{mt_user_id} AND i.company_type = 'Merchant' AND m.id = i.company_id \
AND g.merchant_id = m.id  AND g.token = #{code} AND g.new_token_at > '#{reset_time}'"
        return find_by_sql(query).first
    end

#   -------------

    def get_all
        order("updated_at DESC")
    end

    def get_unsettled end_date
        end_date = if end_date
            # turn end_date into a the UTC time
            end_date.to_date + 7.hours
        else
            Time.now.to_date + 7.hours         # most recent 2 week end period , 7 am
        end
        puts "HEERE IS THE END DATE TO SCOPE #{end_date}"
        where(status: "redeemed").where("pay_stat != :settled", :settled => 'settled').where("updated_at <= :end_date", :end_date => end_date )
    end

    def boomerangable
        boom_time = 30.days
        if Rails.env.staging?
            boom_time = 30.days
        end
        boom_time  = Time.now.utc - boom_time
        where("active AND status = 'incomplete' AND giver_type = 'User' AND (created_at < ?) AND giver_id != 62", boom_time)
    end

    def scheds
        where(active: true, status: 'schedule').order(scheduled_at: :asc)
    end

#### USER SCOPES

    def get_gifts user
        includes(:merchant).includes(:giver).where(receiver_id: user.id).where(pay_stat: ["charge_unpaid", "refund_comp"]).where("status = :open OR status = :notified", :open => 'open', :notified => 'notified').order("updated_at DESC")
    end

    def get_notifications user
        where(receiver_id: user.id).where(pay_stat: ["charge_unpaid", "refund_comp"]).where(status: 'open').size
    end

    def get_past_gifts user
        where( receiver_id: user).where(status: 'redeemed').order("redeemed_at DESC")
    end

    def get_buy_history user
        gifts       = where( giver_id: user).where("status = :open OR status = :notified OR status = :incom", :open => 'open', :notified => 'notified', :incom => "incomplete").order("created_at DESC")
        past_gifts  = where( giver_id: user).where(status: 'redeemed').order("created_at DESC")
        return gifts, past_gifts
    end

    def get_archive user
        give_gifts = includes(:merchant).includes(:receiver).where(giver_id: user).order("created_at DESC")
        rec_gifts  = includes(:merchant).includes(:giver).where(receiver_id: user).where(status: ['regifted','redeemed']).order("redeemed_at DESC")
        return give_gifts, rec_gifts
    end

    def get_user_activity user
        giver_gifts = includes(:merchant).includes(:giver).where(active: true).where.not(pay_stat: ['unpaid', 'payment_error']).where(giver_id: user.id, giver_type: "User").order("created_at DESC")
        rec_gifts   = includes(:merchant).includes(:giver).where(active: true).where.not(pay_stat: ['unpaid', 'payment_error'], status: 'schedule').where(receiver_id: user.id).order("created_at DESC")
        (giver_gifts + rec_gifts).uniq { |g| g.id }
    end

    def get_user_activity_in_client user, client_or_id=nil
        if client_or_id.nil?
            get_user_activity user
        else
            client = client_or_id.kind_of?(Client) ? client_or_id : Client.find(client_or_id)
            if client.full?
                get_user_activity user
            elsif client.partner?
                partner = client.partner
                giver_gifts = includes(:merchant).includes(:giver).where(active: true, partner_type: partner.class.to_s, partner_id: partner.id, giver_id: user.id, giver_type: "User").where.not(pay_stat: ['unpaid', 'payment_error']).order("created_at DESC")
                rec_gifts   = includes(:merchant).includes(:giver).where(active: true, partner_type: partner.class.to_s, partner_id: partner.id, receiver_id: user.id).where.not(pay_stat: ['unpaid', 'payment_error'], status: 'schedule').order("created_at DESC")
                (giver_gifts + rec_gifts).uniq { |g| g.id }
            else    # client.client?
                giver_gifts = includes(:merchant).includes(:giver).where(active: true, client_id: client.id, giver_id: user.id, giver_type: "User").where.not(pay_stat: ['unpaid', 'payment_error']).order("created_at DESC")
                rec_gifts   = includes(:merchant).includes(:giver).where(active: true, client_id: client.id, receiver_id: user.id).where.not(pay_stat: ['unpaid', 'payment_error'], status: 'schedule').order("created_at DESC")
                (giver_gifts + rec_gifts).uniq { |g| g.id }
            end
        end
    end

    def transactions user
        gifts_raw = where(giver_id: user.id, status: ["open","redeemed", "notified", "incomplete", 'schedule']).order("created_at DESC")
        gifts_raw.map do |g|
            gift_hash               = g.serializable_hash only: [ :provider_name, :total, :receiver_name]
            gift_hash["gift_id"]    = g.id
            gift_hash["created_at"] = g.created_at.to_date.inspect
            gift_hash
        end
    end

##### PROVIDER SCOPES

    def get_provider merchant  #indexed
        where(merchant_id: merchant).where("pay_stat not in (?)", ['unpaid']).where("status = :open OR status = :notified OR status = :incomplete", :open => 'open', :notified => 'notified', :incomplete => 'incomplete').order("updated_at DESC")
    end

    def get_history_provider merchant #indexed
        where(merchant_id: merchant.id, status: "redeemed").order("redeemed_at DESC")
    end

    def get_history_provider_and_range merchant, start_date=nil, end_date=nil
        if start_date && end_date
            start_date = start_date + 4.hours
            end_date   = end_date   + 4.hours
            puts "GETTING the gifts scoped with start time = #{start_date} and end_date = #{end_date}"
            where(merchant_id: merchant.id, status: "redeemed").where("redeemed_at >= :start_date AND redeemed_at < :end_date", :start_date => start_date, :end_date => end_date ).order("redeemed_at DESC")
        else
            get_history_provider(provider)
        end
    end

end
