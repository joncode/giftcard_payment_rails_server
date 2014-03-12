module SmsCollector

	def self.sms_promo textword
		puts "------------- SMS Promo for #{textword} -----------------"
		
		campaign_item = CampaignItem.includes(:campaign).find_by(textword: textword.to_s)
		if campaign_item.present?
			if (campaign_item.campaign.live_date < Time.now) && (campaign_item.campaign.close_date > Time.now)
				sms_obj = Slicktext.new(textword, 1000)
				sms_obj.sms
				contacts = sms_obj.contacts
				puts "total contacts = #{sms_obj.count}"

				if contacts.kind_of?(Array)
					if contacts.first.kind_of?(Hash)
						puts "HERE IS THE SAVE CONTACT"
						SmsContact.bulk_create(contacts)
					end
				end

				sms_contacts  = SmsContact.where(gift_id: nil, textword: textword.to_s)
				puts "here is the sms contacts back from db == #{sms_contacts.count}"

				sms_contacts.each do |sms_contact|

					gift = self.create_gift(campaign_item, sms_contact)
					puts "creating a gift for #{sms_contact.inspect}"

					if gift.id.nil?
						puts "Errors = #{gift.errors.messages}"
					else
						puts "gift ID = #{gift.id}"
					end
				end
			else
				word = "not started yet" if campaign_item.campaign.live_date > Time.now
				word = "finished" if campaign_item.campaign.close_date < Time.now
				puts "Campaign has #{word}"
			end
		else
			puts "no campaign item for #{textword.to_s}"
		end

	end

	def self.sms_promo_run
		["itsonme", "drinkboard", "its on me", "no kid hungry"].each do |word|
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
