class AlertMessage < ActiveRecord::Base
	# example AlertMessage
	# { id: m.id, target_id: 41672, target_type: 'Gift', alert_contact_id: 34, msg: 'Gift has been purchased'
	# status: ['unsent', 'sent', 'failed'], reason: 'Number does not exist' }

#   -------------

	after_commit :send_message, on: :create

#   -------------

	validates_presence_of :target_id, :target_type, :alert_contact_id, :msg, :status

#   -------------

	belongs_to :alert_contact
	alias_method :contact, :alert_contact

#   -------------

	def alert
		self.alert_contact.alert
	end

#   -------------

	def self.run alert_contact, status=nil
		puts "AlertMessage - perfom #{alert_contact.inspect}"
		# save pre message to DB
		status ||= 'unsent'
		create(target_id: alert_contact.target.id,
			target_type: alert_contact.target.class.to_s,
			alert_contact_id: alert_contact.id,
			msg: alert_contact.alert.msg,
			status: status )
		# execute send message on background queue
		# update pre message with results
	end

	def send_message
		return if self.status != 'unsent'
		alert_contact = self.alert_contact
		if alert_contact.net == 'phone'
			r = OpsTwilio.text to: alert_contact.net_id, msg: self.msg
		elsif alert_contact.net == 'email'
			# send email message
		else
			self.update(status: 'failed', reason: 'alert_contact.net does not exist')
		end
		if r[:status] == 1
			self.update(status: 'sent')
		else
			self.update(status: 'failed', reason: "Failed to deliver message #{r[:data].inspect}")
		end
	end
end
