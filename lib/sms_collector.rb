module SmsCollector

	def self.sms_promo textword
		puts "------------- SMS Promo for #{textword} -----------------"
			# gets data from slicktext
		sms_obj = Slicktext.new(textword, 1000)
		sms_obj.sms
		contacts = sms_obj.contacts
		puts "total contacts = #{sms_obj.count}"
		# puts "resp = #{sms_obj.resp}"
			# saves that data in sms_contact db
		if contacts.kind_of?(Array)
			if contacts.first.kind_of?(Hash)
				puts "HERE IS THE SAVE CONTACT"
				SmsContact.bulk_create(contacts)
			end
		end
			# generates a gift_campaign per phone number saved
		campaign_item = CampaignItem.find_by(textword: textword.to_s)
		if campaing_item.present?
			sms_contacts  = SmsContact.where(gift_id: nil, textword: textword.to_s)

			sms_contacts.each do |sms_contact|
				gift = self.create_gift(campaign_item, sms_contact)
			end
		else
			puts "no campaign item for #{textword.to_s}"
		end

	end

	def self.sms_promo_run
		["15894", "15893", "15892", "17429"].each do |word|
			self.sms_promo word
		end
	end

private

	def self.create_gift campaign_item, sms_contact
			# associate the sms_contact with the gift
		gift_hash = { "receiver_phone" => sms_contact.phone, "payable_id" => campaign_item.id, "sms_contact" => sms_contact }
		gift = GiftCampaign.create(gift_hash)
	end

	def what_does_it_do
		sms_data = SlicktextGateway.new(textword: textword, limit: 1000)
		contact_params_array = sms_data.contacts
		if sms_data.status == 200

			campaign_items = CampaignItem.all
			SmsContact.where(gift_id:nil).each do |sms|
				campaign_item = campaign_items.where(textword: sms.textword).first
				gift_hash = {receiver_name: "#{campaign.name} gift", receiver_phone: sms.phone, payable_id: campaign_item.id}
				GiftCampaign.create(gift_hash)
			end
			success "#{contact_params_array.count} new contacts added to SMS database"
		else
			fail "connection with sms gateway failed."
		end

	end

end
