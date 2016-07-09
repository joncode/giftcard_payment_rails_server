class AlertMessage < ActiveRecord::Base
    include Email
	# example AlertMessage
	# { id: m.id, target_id: 41672, target_type: 'Gift', alert_contact_id: 34, msg: 'Gift has been purchased'
	# status: ['unsent', 'sent', 'failed'], reason: 'Number does not exist' }

#   -------------

	after_commit :send_message, on: :create

#   -------------

	validates_presence_of :alert_contact_id, :msg, :status

#   -------------

	belongs_to :alert_contact
	alias_method :contact, :alert_contact

#   -------------

	def alert
		self.alert_contact.alert
	end

	def target
		@target ||= (self.target_type.constantize.find(self.target_id))
	end

#   -------------

	def self.run alert_contact, status=nil
		puts "AlertMessage - perfom #{alert_contact.inspect}"
		# save pre message to DB
		status ||= 'unsent'
		target_id = alert_contact.target ? alert_contact.target.id : nil
		target_type = alert_contact.target ? alert_contact.target.class.to_s : nil
		if alert_contact.net == 'phone'
			message = alert_contact.alert.text_msg
		elsif alert_contact.net == 'email'
			message = alert_contact.alert.email_msg
		else
			message = alert_contact.alert.msg
		end
		create(target_id: target_id,
			target_type: target_type,
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
			email_data_hsh = {
				"subject" => "ItsOnMe Alert",
				"html"    => "<div><h2>You've received and alert</h2><p>#{self.msg}</p></div>".html_safe,
				"email"   => alert_contact.net_id
			}
			puts email_data_hsh.inspect
			res = notify_developers(email_data_hsh)
			if res
				r = { status: 1 , data: "Success" }
			else
				r = { status: 0, data: res.inspect }
			end
		else
			self.update(status: 'failed', reason: 'alert_contact.net does not exist')
		end
		if r[:status] == 1
			self.update(status: 'sent')
		else
			self.update(status: 'failed', reason: "Failed to deliver message #{r[:data].inspect}")
		end
	rescue => e
		self.update(status: 'failed', reason: e.inspect)
	end
end
