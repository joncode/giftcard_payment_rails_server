class AddNewStatusToGifts < ActiveRecord::Migration

    def up
        add_column :gifts, :pay_stat,    :string
        add_column :gifts, :pay_type,    :string
        add_column :gifts, :pay_id,      :integer
        add_column :gifts, :redeemed_at, :datetime
        add_column :gifts, :server,      :string

        add_index :gifts, :status
        add_index :gifts, :pay_stat

        add_pay_stat


    end

    def down
        undo_pay_stat

        remove_index :gifts, :status
        remove_index :gifts, :pay_stat

        remove_column :gifts, :pay_stat
        remove_column :gifts, :pay_type
        remove_column :gifts, :pay_id
        remove_column :gifts, :redeemed_at
        remove_column :gifts, :server


    end

    def undo_pay_stat
        gifts = Gift.unscoped

        gifts.each do |gift|
            undo_legacy_gift_status gift
            gift.save
        end
        nil
    end

    def undo_legacy_gift_status gift
        case gift.pay_stat
        when 'unpaid'
            gift.status   = "unpaid"
        when "refunded"
            gift.status   = "refund_cancel"
        when "void"
            gift.status   = "void"
        when "settled"
            gift.status   = "settled"
        end
    end

    def add_pay_stat
        gifts = Gift.unscoped

        new_gifts = gifts.each do |gift|
            set_legacy_gift_status gift
            gift.save
            puts "----------------------"
            puts "Gift #{gift.id} - #{gift.status} | #{gift.pay_stat} | #{gift.server} | #{gift.redeemed_at}"
        end

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
end
