module ProductionDbUpdate


    def run_db_update
        update_gifts
        regift_payables
        change_pay_stats
        add_payment_error
        nil
    end

    def undo_db_update
        undo_change_pay_stats
        nil
    end



    def add_payment_error
        gs = Gift.unscoped
        gs.each do |gift|
            if ["unpaid", "declined", "duplicate"].include?(gift.status)
                gift.status = "payment_error"
                gift.save
            end
        end
    end

private
    def update_gifts
        gs = Gift.unscoped
        total = gs.count
        good = 0
        bad = 0
        save = 0
        gs.each do |gift|
            gift.giver = User.unscoped.find(gift.giver_id)
            gift.value = gift.total
            puts "HERE IS VALUE ___________________ #{gift.value}"
            payable = gift.sale
            if payable
              good += 1
              gift.payable = payable
            end
            if  gift.save
                puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                puts "#{gift.id} / #{gift.value} / #{gift.total} / #{gift.giver_type}"
                save += 1
            else
              bad += 1
                puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                puts "FAIL --------- FAIL --------- gift ID #{gift.id} #{gift.errors.full_messages} #{gift.status}------------- FAIL -------------- FAIL"
                puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            end
        end
        puts "MOVE Giver type and value / make payable a sale"
        puts "Updated = #{good}"
        puts "Saved = #{save}"
        puts "Total = #{total}"
        puts "No Saves = #{bad}"
        tot = good + bad
        puts "Counted = #{tot}"
    end

    def regift_payables
        regifts = Gift.unscoped.where(status: "regifted")
        total = regifts.count
        good = 0
        bad = 0
        no_gift = 0
        regifts.each do |old_gift|
           puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            new_gift = old_gift.child
            if new_gift
              new_gift.payable = old_gift
              if new_gift.save
                good += 1
              else
                bad += 1
                  puts  "NEW GIFT FAIL --------- NEW GIFT FAIL --------- gift ID #{new_gift.id} #{new_gift.errors.full_messages} ------------- NEW GIFT FAIL -------------- NEW GIFT FAIL\n"
              end
            else
              no_gift += 1
              puts "NO NEW GIFT FOR ------------------------------->>>>>> #{old_gift.id}"

            end
             puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        end

        puts "MOVE Regift gift to payable"
        puts "Updated = #{good}"
        puts "Total = #{total}"
        puts "Not Saved = #{bad}"
        tot = good + bad + no_gift
        puts "Counted = #{tot}"
        puts "regift with no child #{no_gift}"

    end

    def change_pay_stats
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

    def undo_change_pay_stats
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