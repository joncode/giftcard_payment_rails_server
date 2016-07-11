class Alert < ActiveRecord::Base
	extend AlertFunctions
	include AlertFunctions
	# example Alert
	# { id: a.id, action: 'merchant', name: 'GIFT_PURCHASED', msg: 'Gift has been purchased', system: 'merchant',
	#  retry_code: 0 }
	# { id: a.id, action: 'merchant', name: 'USE_GIFT_PRESSED', msg: 'Customer is trying to redeem a gift now',
	#  system: 'merchant', retry_code: 0 }

#   -------------

	validates_presence_of :name, :system

#   -------------

	has_many :alert_contacts
	alias_method :contacts, :alert_contacts

	has_many :alert_messages, through: :alert_contacts
	alias_method :messages, :alert_messages

#   -------------

	attr_accessor :target

#   -------------

	def self.perform alert_name, target=nil
		if target.respond_to?(:id)
			puts "Alert - perfom #{alert_name} #{target.id}"
		else
			puts "Alert - perfom #{alert_name} #{target}"
		end
		alert = find_by(name: alert_name)
		if alert.nil?
			alert = create_alert(alert_name)
		end
		alert.target = target
		AlertContact.perform alert
	end

	def note
		note_for(self.name, target)
	end

	def text_msg
		message_for(self.name, target, 'phone')
	end

	def email_msg
		message_for(self.name, target, 'email')
	end

	def msg
		message_for(self.name, target)
	end
	alias_method :message, :msg

end
