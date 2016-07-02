class AlertContact < ActiveRecord::Base
	# example AlertContact
	# { id: r.id, note_id: 45, note_type: 'Merchant', alert_id: a.id, net: 'phone', net_id: '2154948383',
	# status: ['live', 'mute', 'stop'] }

#   -------------

	validates_presence_of :net, :net_id, :alert_id, :user_id, :user_type
    validates :net_id , format: { with: VALID_PHONE_REGEX }, :if => :phone?
    validates :net_id , format: { with: VALID_EMAIL_REGEX }, :if => :email?

#   -------------

	has_many :alert_messages
	alias_method :messages, :alert_messages
	belongs_to :alert

#   -------------

	attr_accessor :target, :note

#   -------------

	def self.perform alert
		puts "AlertContact - perfom #{alert.inspect}"
		if alert.note.nil? && alert.system == 'admin'
			alert_contacts = where(alert_id: alert.id)
		else
			alert_contacts = where(note_id: alert.note.id, note_type: alert.note.class.to_s, alert_id: alert.id)
		end
		alert_contacts.each do |alert_contact|

			alert_contact.alert = alert
			alert_contact.target = alert.target
			alert_contact.note = alert.note
			alert_contact.send_message

		end
	end

	def send_message
		if self.status == 'live'
			AlertMessage.run(self)
		end
	end

#   -------------

	def user
		if self.user_type.nil?
			nil
		else
			self.user_type.constantize.find self.user_id
		end
	end

	def user_name
		if self.user
			self.user.name
		else
			""
		end
	end

#   -------------

	def phone?
		self.net == 'phone'
	end

	def phone= number
		num_regex =
		self.net_id = number
		self.net = 'phone'
	end

	def phone
		if self.net == 'phone'
			self.net_id
		end
	end

	def email?
		self.net == 'email'
	end

	def email= address
		self.net_id = address
		self.net = 'email'
	end

	def email
		if self.net == 'email'
			self.net_id
		end
	end

end
