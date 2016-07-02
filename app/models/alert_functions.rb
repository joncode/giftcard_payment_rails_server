module AlertFunctions
	include MoneyHelper

	def create_alert name
		OpsTwilio.text_devs msg: "Alert Auto-generated for #{name}"
		create({name: name, system: "admin",
			title: name.humanize, detail: "This is an alert for #{name.humanize.downcase} - (Auto-generated)."})
	end

	def message_for name, target
		case name
		when 'GIFT_PURCHASED_SYS'
			"Gift has been purchased for #{display_money(ccy: target.ccy, cents: target.value_cents)}"
		when 'GIFT_PURCHASED'
			"Gift has been purchased for #{display_money(ccy: target.ccy, cents: target.value_cents)}"
		when 'CARD_FRAUD_DETECTED_SYS'
			"Alert- Card fraud possible for #{target.name} - ID(#{target.id}"
		when 'GIFT_FRAUD_DETECTED_SYS'
			"Alert- Gift fraud possible for #{target.giver_name} - ID(#{target.id}"
		end
	end

	def note_for name , target
		case name
		when 'GIFT_PURCHASED_SYS'
			nil
		when 'GIFT_PURCHASED'
			target.merchant
		when 'CARD_FRAUD_DETECTED_SYS'
			target
		when 'GIFT_FRAUD_DETECTED_SYS'
			target
		end
	end

end