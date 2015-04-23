class PaymentCalcCronJob

    @queue = :database

    def self.perform start_date=nil
        puts "\n-------------    PAYMENT CALC CRON     -------------"
        if start_date.kind_of?(String)
            start_date = Date.parse(start_date)
        end
        return "Not running" unless should_payment_cron_run?(start_date)

        sd = start_date || Payment.get_start_date_of_payment
        ed = Payment.get_end_date_of_payment(sd)

        registers = Register.where(created_at: sd ... ed)

        registers.each do |reg|

            next unless reg.payment_id.nil? # already paid
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

    def self.should_payment_cron_run?(start_date)
        return true if start_date
        ed = Payment.get_end_date_of_payment
        DateTime.now.utc.day == ed.day
    end

end