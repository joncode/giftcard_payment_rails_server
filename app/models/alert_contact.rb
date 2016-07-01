class AlertContact < ActiveRecord::Base
	# example AlertContact
	# { id: r.id, note_id: 45, note_type: 'Merchant', alert_id: a.id, net: 'phone', net_id: '2154948383',
	# status: ['live', 'mute', 'stop'] }

	validates_presence_of :net, :net_id, :note_id, :note_type, :alert_id

	attr_accessor :alert, :target, :note

	def self.perform alert
		alert_contacts = where(note_id: alert.note.id, note_type: alert.note.class.to_s, alert_id: alert.id)
		alert_contacts.each do |alert_contact|

			alert_contact.alert = alert
			alert_contact.target = alert.target
			alert_contact.note = alert.note
			alert_contact.contact

		end
	end

	def contact
		if self.status == 'live'
			AlertMessage.perform(self)
		end
	end
end
