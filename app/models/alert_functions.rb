module AlertFunctions
	include MoneyHelper

	def message_for name, target
		case name
		when 'GIFT_PURCHASED_SYS'
			"Gift has been purchased for #{display_money(ccy: target.ccy, cents: target.value_cents)}"
		when 'GIFT_PURCHASED'
			"Gift has been purchased for #{display_money(ccy: target.ccy, cents: target.value_cents)}"
		end
	end

	def note_for name , target
		case name
		when 'GIFT_PURCHASED_SYS'
			nil
		when 'GIFT_PURCHASED'
			target.merchant
		end
	end

end