# A. runs once per day
# generate registers, invoices, and processs payments for money owed to IOM
class AccountsReceivableCronJob

    @queue = :subscription

    def self.perform

        # B. generate the recurring registers
        AccountsReceivable.make_registers_and_invoices

        # D. process the payment
        AccountsReceivable.process
    end
end
