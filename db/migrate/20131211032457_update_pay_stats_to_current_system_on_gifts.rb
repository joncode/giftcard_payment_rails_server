class UpdatePayStatsToCurrentSystemOnGifts < ActiveRecord::Migration
    def up
        gs = Gift.unscoped
        gs.each do |gift|
            case gift.pay_stat
            when "charged"
                if gift.status == 'regifted'
                    gift.pay_stat = 'charge_regifted'
                else
                    gift.pay_stat = 'charge_unpaid'
                end
                gift.save
            when "settled"

            when "unpaid"

            when "refunded"
                if gift.status == 'cancel'
                    gift.pay_stat = 'refund_cancel'
                else
                    gift.pay_stat = 'refund_comp'
                end
                gift.save
            when "void"
                if gift.status == 'cancel'
                    gift.pay_stat = 'refund_cancel'
                else
                    gift.pay_stat = 'refund_comp'
                end
                gift.save
            else
                puts "--------------------------------------------"
                puts "INKNOWN PAY STAT  !!!!!"
                puts "#{gift.pay_stat}"
                puts "--------------------------------------------"
                puts "--------------------------------------------"
            end

        end
    end

    def down
        gs = Gift.unscoped
        gs.each do |gift|
            case gift.pay_stat
            when 'charge_regifted'
                gift.pay_stat = 'charged'
                gift.save
            when "charge_unpaid"
                gift.pay_stat = 'charged'
                gift.save
            when "charge_settled"
                gift.pay_stat = "settled"
                gift.save
            when "unpaid"

            when "refund_comp"
                gift.pay_stat = 'refund'
                gift.save
            when "refund_cancel"
                gift.pay_stat = 'refund'
                gift.save
            else
                puts "--------------------------------------------"
                puts "INKNOWN PAY STAT  !!!!!"
                puts "#{gift.pay_stat}"
                puts "--------------------------------------------"
                puts "--------------------------------------------"
            end
        end
    end
end




# GIFT PAY STAT
# unpaid          11   unpaid_unpaid_unpaid
# void_cancel     12   void_cancel_cancel
# refund_cancel   13   refund_cancel_cancel
# refund_expired  14   refund_expired_expired
# void_comp       15   void_comp_comp
# refunded_comp   16   refund_comp_comp
# charge_unpaid   17   charge_unpaid_settled
# charge_settled  18   charge_settled_unpaid
# charge_regifted 19   charge_nil_nil
# settled         20   charge_settled_settled
