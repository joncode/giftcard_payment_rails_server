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

	def alert_contact
		ac = super
		ac.target ||= self.target
		ac
	end

#   -------------

	def alert
		a = self.alert_contact.alert
		a.target ||= self.target
		a
	end

	def target
		return nil if self.target_type.nil?
		@target ||= self.target_type.constantize.unscoped.where(id: self.target_id).first
	end

	def destroy
			# DO NOT DELETE RECORDS
		update_column(:active, false)
	end

#   -------------

	def self.run alert_contact, status='unsent'
		puts "AlertMessage - perfom #{alert_contact.inspect}"
		# save pre message to DB

		if alert_contact.target.respond_to?(:id)
			target_id = alert_contact.target ? alert_contact.target.id : nil
			target_type = alert_contact.target ? alert_contact.target.class.to_s : nil
		end

		message = if alert_contact.net == 'phone'
			alert_contact.alert.text_msg
		elsif alert_contact.net == 'email'
			alert_contact.alert.email_msg
		else
			alert_contact.alert.msg
		end
		return if message.blank?
		create(target_id: target_id,
			target_type: target_type,
			alert_contact_id: alert_contact.id,
			msg: message,
			status: status )
		# execute send message on background queue
		# update pre message with results
	end

	def send_message
		return self.status if self.status != 'unsent'
		alert_contact = self.alert_contact
		if alert_contact.net == 'phone'
			r = OpsTwilio.text to: alert_contact.net_id, msg: self.msg
		elsif alert_contact.net == 'email'
			email_data_hsh = {
				"subject" => "ItsOnMe Alert",
				"html"    => "<div><p>#{self.msg}</p></div>".html_safe,
				"email"   => alert_contact.net_id
			}
			# puts 'AlertMessage' + email_data_hsh.inspect
			email_obj = EmailAlerts.new(email_data_hsh)
			res = email_obj.send_email
			if res
				r = { status: 1 , data: "Success" }
			else
				r = { status: 0, data: res.inspect }
			end
		else
			update(status: 'failed', reason: "#{alert_contact.net} does not exist")
		end
		if r[:status] == 1
			update(status: 'sent')
		else
			update(status: 'failed', reason: "Failed to deliver message #{r[:data].inspect}")
		end
	rescue => e
		update(status: 'failed', reason: e.inspect)
	end
end
