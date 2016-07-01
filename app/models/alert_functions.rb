module AlertFunctions
	include MoneyHelper

	def message_for name, target
		case name
		when 'GIFT_PURCHASED'
			"Gift has been purchased for #{display_money(ccy: target.ccy, cents: target.value_cents)}"
		end
	end

	def note_for name , target
		case name
		when 'GIFT_PURCHASED'
			taget.merchant
		end
	end

end