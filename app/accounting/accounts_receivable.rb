class AccountsReceivable

	class << self

		def check_licenses
			# get all the merchants and make sure they have a license
			# get all the partners and make sure they have licenses
				# count up all golfnow licenses and make sure they are covered
			# alert team if there is a license issue
			# auto-renew any licenses up for auto-renewal today

		end

		def make_registers_and_invoices
				# 	1. gets all the licenses
			License.get_live.each do |license|
				register license
			end
			# MUST calculate all the licenses before
			# C. generate the invoice and send
			AccountsReceivable.make_invoices
		end

		def register license
			return nil unless license.make_register_today?
				# 	2. asks the license for a charge object
			hsh = license.charge_object
				# 	3. makes a register with the charge object
			reg = Register.create_with_charge_object(hsh)
				# 	4. saves the register
			if reg.save
				# success
			else
				msg = "REGISTER FAIL #{reg.errors.full_messages}"
				puts msg.inspect
				OpsTwilio.text_devs msg: msg
			end
			reg
		end

		def invoice_and_notify
				# 	1. gets all the licenses
			invoice_obj = {}
			Register.get_unpaid_invoices.each do |register|
				key = "#{register.partner_type}-#{register.partner_id}"
				if invoice_obj[key].nil?
					invoice_obj[key] = [register]
				else
					invoice_obj[key] << register
				end
			end
			invoices = []
			invoice_obj.each do |k , ary|
				invoices << make_invoice ary
			end
				# 	3. notify the receiving company
			invoice.each do |invoice|
				invoice.notify_customer
			end
		end

		def self.make_invoice registers
				# 	2. make the time period
			invoice = Payment.new
			invoice.type_of = 'invoice'
			invoice.amount = 0
			invoice.paid = false
			if invoice.save
				registers.each do |reg|
					invoice.start_date = reg.license.start_date if invoice.start_date.nil?
					invoice.end_date = reg.license.end_date if invoice.end_date.nil?

					# 	1. total the registers
					invoice.amount += reg.amount
				end
			else
				msg = "INVOICE FAIL #{invoice.errors.full_messages}"
				puts msg.inspect
				OpsTwilio.text_devs msg: msg
			end
		end

		def self.process
			Payment.get_unpaid_invoices.each do |invoice|
				# 	1. get the payment from the database
				# 	2. charge / process the payment
				# 	3. update the payment with transaction ID info
				if invoice.charge?
					resp = OpsStripe.pay_invoice(invoice)
					if resp.success?
						invoice.response = resp.response
						invoice.transaction_id = resp.transaction_id
						invoice.paid = true
						if invoice.save
							# alert Craig ? do nothing ?
						else
							msg = "PAYMENT SUCCEED / INVOICE FAIL #{invoice.errors.full_messages} #{resp.inpect}"
							puts msg.inspect
							OpsTwilio.text_devs msg: msg
						end
					else

					end
				else
					invoice.notify_accountants
				end
			end
		end

	end

end