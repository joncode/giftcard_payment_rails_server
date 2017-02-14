# A. runs once per day
# generate registers, invoices, and processs payments for money owed to IOM
class AccountsReceivableCronJob

    @queue = :subscription

    def self.perform
    	puts "AccountsReceivableCronJob"

		# A. auto-renew , alert and update variable amount licenses
		AccountsReceivable.check_licenses

		# B. generate the recurring registers
		AccountsReceivable.make_registers

		# D. process the payment
		# AccountsReceivable.process
	rescue => e
		puts "500 Internal AccountsReceivableCronJob #{e.inspect}"
    end
end
