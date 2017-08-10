class AccountsPayableCronJob

    # AccountsPayableCronJob.perform
    @queue = :database

    def self.perform start_date=nil
        puts "\n-------------    PAYMENT CALC CRON  #{start_date}   -------------"
        if start_date.kind_of?(String)
            start_date = Date.parse(start_date)
        end
        return "AccountsPayableCronJob - Not running" unless should_payment_cron_run?(start_date)

        sd = start_date || Payment.get_start_date_of_payment
        sd = sd.beginning_of_day
        ed = Payment.get_end_date_of_payment(sd)

        registers = Register.get_unpaid_in_range start_date: sd, end_date: ed
        # registers = Register.where(created_at: sd ... ed, payment_id: nil)
        # registers = Register.where('payment_id IS NULL AND created_at < ?', ed)

        registers.each do |reg|

            next if reg.subscription?
            next if self.already_paid?(reg) # already paid
            partner = reg.partner

            next if partner.nil?  # cannot create a payment if no partner - this is error
            payment = Payment.get_current_payment_for_partner(partner, sd)

            next if reg.ccy != 'USD'

            if reg.debt?
                case reg.payment_type
                when :merchant
                    payment.m_transactions += 1
                    payment.m_amount += reg.amount
                when :user
                    payment.u_transactions += 1
                    payment.u_amount += reg.amount
                when :link
                    payment.l_transactions += 1
                    payment.l_amount += reg.amount
                else
                    puts "PAYMENT / REGISTER ORIGIN UNKNOWN ERROR 500 Internal -- #{reg.inspect}"
                    next
                end
                payment.revenue += reg.amount
            else
                # register is a Credit - reg.amount returns a negative value - saved on payment on a positive
                payment.refund += reg.amount
            end
            payment.total = payment.revenue + payment.refund + payment.previous_total
            if payment.total > 0
                payment.payment_amount = payment.total
            else
                payment.payment_amount = 0
            end
            payment.end_date = ed if payment.end_date.nil?
            payment.registers << reg
            payment.save
        end
        return 'AccountsPayableCronJob - Completed'
    end

    def self.should_payment_cron_run?(start_date)
        return true if start_date
        ed = Payment.get_end_date_of_payment
        DateTime.now.utc.day == ed.day
    end

    def self.already_paid? reg
        return true if reg.payment_id.present?
        if reg.credit?
            return false
        end
        if reg.gift.nil? || reg.gift.do_not_pay? || reg.gift.revenue_already_transfered?
            return true
        end
        if reg.gift.status == 'regifted'
            return self.gift_already_paid_via_child?(reg.gift)
        end
        return false
    end

    def self.gift_already_paid_via_child? parent
        gift = parent.child
        if gift.nil?
            return true
        end
        if gift.status == 'regifted'
            self.gift_already_paid_via_child? gift
        else
            gift.do_not_pay? || gift.revenue_already_transfered?
        end
    end

end

# Register needs a Register.get_unpaid_registers

#     create start date and end_date

#     set end_date
#         if today is before the 16th , end_date is beginning of this month
#         if today is after the 16th , end_date is the beginning of day on the 16th

#     rs = Register.where.not(payment_id: nil).where(created_at < end_date)
#         # also, do not get registers beyond the pay period

#     unpaids = rs.select do  |reg|
#         !(reg.gift.nil? || reg.gift.pay_stat == 'settled' || !reg.gift.active || reg.gift.status == 'cancel' || reg.gift.pay_stat == 'payment_error')
#     end

#     unpaids.each do |reg|

#         partner = reg.partner
#         next if partner.nil?  # cannot create a payment if no partner - this is error
#         payment = Payment.where(partner: partner, paid: false)

#         set start_date
#             if payment.start_date > register.created_at ?
#                 set payment_date to include register created_at

#         set end_date



#         case statement
#         payment totals and save


#     end








