module LegacyGift

    def add_pay_stat
        gifts = Gift.unscoped

        new_gifts = gifts.each do |gift|
            set_legacy_gift_status gift
            gift.save
        end
        pattr [:status, :pay_stat, :pay_type, :redeemed_at, :server], new_gifts
        nil
    end


    def set_legacy_gift_status gift
        case gift.status
        when "unpaid"
            gift.pay_stat = "unpaid"
            gift.status   = "cancel"
            get_redeemed_at(gift)
        when "incomplete"
            gift.pay_stat = "charged"
        when "open"
            gift.pay_stat = "charged"
        when "notified"
            gift.pay_stat = "charged"
        when "redeemed"
            gift.pay_stat = "charged"
            get_redeemed_at(gift)
        when "regifted"
            gift.pay_stat = "charged"
            get_redeemed_at(gift)
        when "refund_cancel"
            gift.pay_stat = "refunded"
            gift.status   = "cancel"
            get_redeemed_at(gift)
        when "void"
            gift.pay_stat = "void"
            gift.status   = "cancel"
            get_redeemed_at(gift)
        when "settled"
            gift.pay_stat = "settled"
            gift.status   = "redeemed"
            get_redeemed_at(gift)
        end
        gift.pay_type = "Sale"
    end

    def get_redeemed_at gift
        if gift.order
            gift.redeemed_at = gift.order.created_at
            gift.server = gift.order.server_code
        else
            nil
        end
    end

    def check_orders
        gs = Gift.unscoped
        gs.each do |g|
            if (g.status == "redeemed") || (g.status == "settled")
                if g.order.nil?
                    puts "gift ID #{g.id}"
                else
                    puts "gift ID #{g.id} has order ID #{g.order.id} - created_at #{g.order.created_at}"
                end
            end
        end
        nil
    end


end


# Gift lifecycle:
# incomplete, open , notified, redeemed, regifted, expired, combined, cancel

# Payment Cycle:
# unpaid, charged, void, refunded, settled, merchant_comped(we still get paid if its a merchant), admin_comped(merchant still gets paid)

# Payment Type:
# Sale, Credit, Merchant, Campaign, Admin
