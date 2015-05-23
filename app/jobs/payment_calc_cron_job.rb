class PaymentCalcCronJob

    @queue = :database

    def self.perform start_date=nil
        puts "\n-------------    PAYMENT CALC CRON  #{start_date}   -------------"
        if start_date.kind_of?(String)
            start_date = Date.parse(start_date)
        end
        return "Not running" unless should_payment_cron_run?(start_date)

        sd = start_date || Payment.get_start_date_of_payment
        sd = sd.beginning_of_day
        ed = Payment.get_end_date_of_payment(sd)

        registers = Register.where(created_at: sd ... ed)
        # binding.pry
        registers.each do |reg|

            next if self.already_paid(reg) # already paid
            next unless reg.debt?   # payments for debts only
            partner = reg.partner

            next if partner.nil?  # cannot create a payment if no partner - this is error

            payment = Payment.where(partner: partner, start_date: sd).first_or_initialize

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

            payment.end_date = ed if payment.end_date.nil?
            payment.total += reg.amount
            payment.registers << reg
            payment.save
        end
    end

    def self.already_paid reg
        !reg.payment_id.nil? || reg.gift.nil? || reg.gift.pay_stat == 'settled' || !reg.gift.active || reg.gift.status == 'cancel' || reg.gift.pay_stat == 'payment_error'
    end

    def self.should_payment_cron_run?(start_date)
        return true if start_date
        ed = Payment.get_end_date_of_payment
        DateTime.now.utc.day == ed.day
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








