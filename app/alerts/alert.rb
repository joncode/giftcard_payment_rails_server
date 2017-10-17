class Alert < ActiveRecord::Base
	include MoneyHelper
	# example Alert
	# { id: a.id, action: 'merchant', name: 'GIFT_PURCHASED', msg: 'Gift has been purchased', system: 'merchant',
	#  retry_code: 0 }
	# { id: a.id, action: 'merchant', name: 'USE_GIFT_PRESSED', msg: 'Customer is trying to redeem a gift now',
	#  system: 'merchant', retry_code: 0 }

#   -------------

	validates_presence_of :name, :system

#   -------------

	has_many :alert_messages, through: :alert_contacts
	alias_method :messages, :alert_messages

#   -------------

	attr_accessor :target

#   -------------

	def self.perform alert_name, target=nil
		if target.respond_to?(:id)
			puts "Alert.rb.perfom #{alert_name} #{target.id}"
		else
			puts "Alert.rb.perfom #{alert_name} #{target}"
		end

		alert = get_alert(alert_name)

		return unless alert && alert.active

		alert.target = target
		AlertContact.perform alert
	end

#   -------------

	def alert_contacts
		if self.system == 'admin'
			AlertContact.where(active: true, alert_id: self.id, user_type: 'AtUser')
		else
			raise "Alert has no TARGET!" unless self.target
			merchant = self.note.merchant if self.note.kind_of?(Gift)
			merchant = self.note

			mtus = AlertContact.where(active: true, note_id: merchant.id, note_type: merchant.class.to_s,
				alert_id: self.id)
			ptus = []
			if merchant.affiliate_id.present?
				if a = Affiliate.where(id: merchant.affiliate_id).first
					ptus = AlertContact.where(active: true, note_id: a.id, note_type: a.class.to_s,
						alert_id: self.id)

				end
			end
			mtus.concat(ptus)
		end
	end

#   -------------

	def self.alert_object name
		begin
			(name + '_ALERT').titleize.gsub(' ','').constantize
		rescue
			Alert
		end
	end

	def self.get_alert alert_name, create_it=true
		alert_klass = alert_object(alert_name)

		alert = alert_klass.find_by(name: alert_name)
		alert = alert_klass.create_alert(alert_name) if ( alert.nil? && create_it )

		alert
	end

	def self.find alert_id
		a = super
		a.subclass
	end

	def subclass
		Alert.get_alert self.name, false
	end

#   -------------

	def link_tag_email src, text
		"<a href='#{src}'>#{text}</a>"
	end

	def link_tag_text src, text
		"\n#{text}\n#{src}\n"
	end

#   -------------

	def destroy
			# DO NOT DELETE RECORDS
		update_column(:active, false)
	end

	def note
		case self.name
		when 'GIFT_PURCHASED_SYS'
			nil
		else
			self.target
		end
	end

	def text_msg
		msg
	end

	def email_msg
		msg
	end

	def msg
		case self.name
		when 'CARD_FRAUD_DETECTED_SYS'
			msg = "Alert- Card fraud possible - fraud activity by #{self.target.name} - ID(#{self.target.id})"
		when 'GIFT_FRAUD_DETECTED_SYS'
			msg = "Alert- Gift(#{self.target.id}) fraud possible - Received by #{self.target.receiver_name} \
- ID(#{self.target.receiver_id}) less than 30 minutes from purchase by giver #{self.target.giver_name} (#{self.target.giver_id}) \
#{display_money(cents: self.target.value_cents, ccy: self.target.ccy)}"
		else
			msg = "Alert- #{Alert.title_for(name)}"
			msg += " for #{self.target.class} - ID(#{self.target.id})" if self.target
		end
		msg
	end

#   -------------

	def self.create_alert name
		puts "\nCreating alert for #{name}"
		OpsTwilio.text_devs msg: "Alert Auto-generated for #{name}"

		create({name: name, system: system_for(name), title: title_for(name),
			detail: "This is an alert for #{title_for(name)} - (Auto-generated)."})
	end

	def self.system_for name
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

	def self.title_for name
		a = name.split('_')
		a.pop
		a.join(' ').titleize
	end

	def name_string
		self.class.to_s.underscore.titleize.gsub('Sys', 'Admin').gsub('Mt', 'Merchant')
	end

	def self.enum_to_class enum
		(enum.downcase + '_alert').camelize
	end

end


# contacts = []a
# merchant = self.note
# merchant_mtus = merchant.mt_users.to_a
# affiliate_mtus = []
# if merchant.affiliate_id.present?
# 	if a = Affiliate.where(id: merchant.affiliate_id).first
# 		affiliate_mtus = a.mt_users.to_a
# 	end
# end
# mtus = affiliate_mtus.concat(merchant_mtus)
# mtus.each do |mtu|
# 	cts = AlertContact.where(user_id: mtu.id, user_type: mtu.class.to_s, alert_id: self.id).to_a
# 	contacts.concat(cts)
# end
# admin_users = MtUser.where(admin: true, active: true)
# admin_users.each do |mtu|
# 	cts = AlertContact.where(user_id: mtu.id, user_type: mtu.class.to_s, alert_id: self.id).to_a
# 	contacts.concat(cts)
# end
# contacts
