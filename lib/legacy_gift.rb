module LegacyGift
    include ActionView::Helpers::NumberHelper

    def add_pay_stat
        gifts = Gift.unscoped

        new_gifts = gifts.each do |gift|
            set_legacy_gift_status gift
            gift.save
        end
        pattr [:status, :pay_stat, :pay_type, :redeemed_at, :server], new_gifts
        nil
    end

    def set_viewed_at
        Gift.unscoped.find_in_batches do |group|
            group.each do |gift|
                if redeem = gift.redeem
                    gift.update_column(:viewed_at, redeem.created_at)
                end
            end
        end
        nil
    end

    def set_ordered_at
        Gift.unscoped.where(status: 'redeemed').find_in_batches do |group|
            group.each do |gift|
                if gift.viewed_at && gift.viewed_at > (gift.redeemed_at - 1.day)
                    gift.update_column(:ordered_at, gift.viewed_at)
                else
                    gift.update_column(:ordered_at, gift.redeemed_at)
                end
            end
        end
        nil
    end

    def return_gifts_with_bad_server_codes
        oss = Order.where('created_at > ?', '2013-10-14 05:27:40.675624')
        oss.select do |ord|
            if gift = ord.gift
                gift.server != ord.server_code
            else
                false
            end
        end
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

    def self.add_cost
        gs = Gift.unscoped
        gs.map do |g|
            if g.cost.blank? || g.cost == "0"
                case g.giver_type
                when  "BizUser"
                    cost = "0"
                when "AdminGiver"
                    cart = JSON.parse(g.shoppingCart)
                    cost = (cart.sum {|x| x["price_promo"].to_f * x["quantity"].to_i }).to_s
                when "User"
                    unless g.value
                        g.value = g.total
                    end
                    cost = (g.value.to_f * 0.85).round(2).to_s
                when "Campaign"
                    cost = g.payable.cost
                else
                    cost = self.set_giver_type(g)
                end

                g.cost = cost.to_s
                if g.save
                    nil
                else
                    puts "gift broken = #{g.errors.messages}"
                    g
                end
            end
        end
    end

    def self.set_giver_type(g)
        case g.cat
        when 0
            g.giver_type = "User"
            unless g.value
                g.value = g.total
            end
            (g.value.to_f * 0.85).round(2).to_s
        when 100
            g.giver_type = "Gift"
            (g.value.to_f * 0.85).round(2).to_s
        when 200
            g.giver_type = "BizUser"
            "0"
        when 210
            g.giver_type = "AdminGiver"
            cart = JSON.parse(g.shoppingCart)
            (cart.sum {|x| x["price_promo"].to_f * x["quantity"].to_i }).to_s
        when 300
            g.giver_type = "Campaign"
            cost = g.payable.cost
        end
    end
end


# Gift lifecycle:
# incomplete, open , notified, redeemed, regifted, expired, combined, cancel

# Payment Cycle:
# unpaid, charged, void, refunded, settled, merchant_comped(we still get paid if its a merchant), admin_comped(merchant still gets paid)

# Payment Type:
# Sale, Credit, Merchant, Campaign, Admin
