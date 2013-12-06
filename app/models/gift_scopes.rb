module GiftScopes

##### GIFT SCOPES

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

#### USER SCOPES

    def get_gifts user
        includes(:provider).includes(:redeem).includes(:giver).where(receiver_id: user.id).where(pay_stat: "charge_unpaid").where("status = :open OR status = :notified", :open => 'open', :notified => 'notified').order("updated_at DESC")
    end

    def get_notifications user
        where(receiver_id: user.id).where(pay_stat: "charge_unpaid").where(status: 'open').size
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
        give_gifts = includes(:provider).includes(:receiver).where(giver_id: user).order("created_at DESC")
        rec_gifts  = includes(:provider).includes(:giver).where(receiver_id: user).where(status: ['regifted','redeemed']).order("redeemed_at DESC")
        return give_gifts, rec_gifts
    end

    def get_user_activity user
        where("giver_id = :user OR receiver_id = :user", :user => user.id).order("created_at DESC")
    end

    def transactions user
        gifts_raw = where(giver_id: user.id, status: ["open","redeemed", "notified", "incomplete"]).order("created_at DESC")
        gifts_raw.map do |g|
            gift_hash               = g.serializable_hash only: [ :provider_name, :total, :receiver_name]
            gift_hash["gift_id"]    = g.id
            gift_hash["created_at"] = g.created_at.to_date.inspect
            gift_hash
        end
    end

##### PROVIDER SCOPES

    def get_provider provider
        where(provider_id: provider).where("pay_stat not in (?)", ['unpaid']).where("status = :open OR status = :notified OR status = :incomplete", :open => 'open', :notified => 'notified', :incomplete => 'incomplete').order("updated_at DESC")
        #where(provider_id: provider).order("updated_at DESC")
    end

    def get_history_provider provider
        where(provider_id: provider.id, status: "redeemed").order("redeemed_at DESC")
        #where(provider_id: provider).order("updated_at DESC")
    end

    def get_history_provider_and_range provider, start_date=nil, end_date=nil
        if start_date && end_date
            start_date = start_date + 4.hours
            end_date   = end_date   + 4.hours
            puts "GETTING the gifts scoped with start time = #{start_date} and end_date = #{end_date}"
            where(provider_id: provider.id, status: "redeemed").where("redeemed_at >= :start_date AND redeemed_at <= :end_date", :start_date => start_date, :end_date => end_date ).order("redeemed_at DESC")
        else
            get_history_provider(provider)
        end
    end

end
