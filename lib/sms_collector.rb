module SmsCollector

	def self.sms_promo word_hsh
		textword = word_hsh["word"]

		campaign_item = CampaignItem.includes(:campaign).find_by(textword: textword.to_s)
		if campaign_item.present?
			if (campaign_item.campaign.live_date < Time.now) && (campaign_item.campaign.close_date > Time.now)
				if campaign_item.reserve > 0
					sms_obj = Slicktext.new(word_hsh)
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
					puts "campaign #{word} reserve is empty"
				end
			else
				word = "not started yet" if campaign_item.campaign.live_date > Time.now
				word = "finished" if campaign_item.campaign.close_date < Time.now
				puts "Campaign #{textword.to_s} has #{word}"
			end
		else
			puts "no campaign item for #{textword.to_s}"
		end

	end

	def self.sms_promo_run
		puts "------------- Slicktext SMS Promo  -----------------"
		textword_hshs = Slicktext.textwords
		textword_hshs.each do |word_hsh|
			self.sms_promo word_hsh
		end
	end

private

	def self.create_gift campaign_item, sms_contact
			# associate the sms_contact with the gift
		gift_hash = { "receiver_phone" => sms_contact.phone, "payable_id" => campaign_item.id, "sms_contact" => sms_contact }
		gift = GiftCampaign.create(gift_hash)
	end


end
