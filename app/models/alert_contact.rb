class AlertContact < ActiveRecord::Base
	include ModelValidationHelper
	include ActionView::Helpers::NumberHelper
	# example AlertContact
	# { id: r.id, note_id: 45, note_type: 'Merchant', alert_id: a.id, net: 'phone', net_id: '2154948383',
	# status: ['live', 'mute', 'stop'] }

#   -------------

    before_validation { |contact| contact.net_id = strip_and_downcase(net_id) if email? }
	before_validation { |contact| contact.net_id = extract_phone_digits(net_id) if phone? }

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

	ALERT_MUTE_HOURS = 12.hours

#   -------------

	def self.statuses
		['live', 'mute', 'stop']
	end

	def form_update p
		if !p[:email].blank? && !p[:phone].blank?
			# both fields filled out - use existing :net
			email = p[:email] if email?
			email = p[:phone] if phone?
		else
			# email
			email = p[:email] unless p[:email].blank?

			# phone
			phone = p[:phone] unless p[:phone].blank?
		end
		self.status = p[:status] if AlertContact.statuses.include?(p[:status])
		self
	end

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

#   -------------

	def unmute_at
		self.updated_at + ALERT_MUTE_HOURS
	end

	def receiving_messages?
		return true if self.status == 'live'
		if self.status == 'mute' && (self.updated_at < ALERT_MUTE_HOURS.ago)
			update(status: 'live')
			return true
		end
		return false
	end

	def send_message
		if self.receiving_messages?
			AlertMessage.run(self)
		else
			AlertMessage.run(self, self.status) if self.status == 'mute'
		end
	end

#   -------------

	def user= user
		self.user_id = user.id
		self.user_type = user.class.to_s
	end

	def user
		@user ||= (self.user_type.constantize.find(self.user_id))
	end

	def user_name
		return self.user.name if self.user
		""
	end

#   -------------

	def net_id display=false
		if display
			display_net_id
		else
			super()
		end
	end

	def display_net_id
		return self.net_id if !self.phone?
		number_to_phone(self.net_id)
	end

#   -------------

	def phone?
		self.net == 'phone'
	end

	def phone= number
		self.net_id = number
		self.net = 'phone'
	end

	def phone
		self.net_id if self.net == 'phone'
	end

#   -------------

	def email?
		self.net == 'email'
	end

	def email= address
		self.net_id = address
		self.net = 'email'
	end

	def email
		self.net_id if self.net == 'email'
	end

end
