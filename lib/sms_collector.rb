module SmsCollector

	def self.sms_promo word_hsh
		textword = word_hsh["word"]

		campaign_item = CampaignItem.includes(:campaign).find_by(textword: textword.to_s)
		if campaign_item.present?
			if campaign_item.live?
				sms_obj = Slicktext.new(word_hsh)
				sms_obj.sms
				contacts = sms_obj.contacts
				puts "total contacts = #{contacts.count}"

				if contacts.kind_of?(Array) && contacts.first.kind_of?(Hash)
					SmsContact.bulk_create(contacts)
				end
				sms_contacts  = SmsContact.where(gift_id: nil, textword: textword.to_s)
				puts "sms contacts from db to gift = #{sms_contacts.count}"
				sms_contacts.each do |sms_contact|
					puts "creating a gift for #{sms_contact.inspect}"
					gift = self.create_gift(campaign_item, sms_contact)
				end
			else
				puts campaign_item.status_text
			end
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
		if gift.id.nil?
			puts "Errors = #{gift.errors.messages}"
		else
			puts "gift ID = #{gift.id}"
		end
	end


end
