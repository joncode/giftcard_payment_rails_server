module AlertFunctions
	include MoneyHelper

	def create_alert name
		puts "\nCreating alert for #{name}"
		OpsTwilio.text_devs msg: "Alert Auto-generated for #{name}"

		create({name: name, system: system_for(name),
			title: title_for(name), detail: "This is an alert for #{title_for(name)} - (Auto-generated)."})
	end

	def system_for name
		a = name.split('_')
		case a.last
		when "SYS"
			'admin'
		when "PT"
			'partner'
		when "MT"
			'merchant'
		else
			'admin'
		end
	end

	def title_for name
		a = name.split('_')
		a.pop
		a.join(' ').titleize
	end

	def message_for name=self.name , target=nil
		res = (name + '_ALERT').titleize.gsub(' ','').constantize
		res.message_for target
	rescue
		case name
		when 'GIFT_PURCHASED_SYS'
			"Gift has been purchased for #{display_money(ccy: target.ccy, cents: target.value_cents)}"
		when 'GIFT_PURCHASED'
			"Gift has been purchased for #{display_money(ccy: target.ccy, cents: target.value_cents)}"
		when 'CARD_FRAUD_DETECTED_SYS'
			"Alert- Card fraud possible for #{target.name} - ID(#{target.id}"
		when 'GIFT_FRAUD_DETECTED_SYS'
			"Alert- Gift fraud possible for #{target.giver_name} - ID(#{target.id}"
		else
			msg = "Alert- #{title_for(name)}"
			msg += " for #{target.class} - #{target.id}" if target
		end
	end

	def note_for name=self.name , target=nil
		case name
		when 'GIFT_PURCHASED_SYS'
			nil
		when 'GIFT_PURCHASED'
			target.merchant
		when 'CARD_FRAUD_DETECTED_SYS'
			target
		when 'GIFT_FRAUD_DETECTED_SYS'
			target
		else
			target
		end
	end

end