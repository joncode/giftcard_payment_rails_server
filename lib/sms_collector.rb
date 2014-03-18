module SmsCollector

	def self.sms_promo word_hsh
		textword = word_hsh["word"]

		campaign_item = CampaignItem.includes(:campaign).find_by(textword: textword.to_s)
		if campaign_item.present?
			if campaign_item.live?
				sms_obj = Slicktext.new(word_hsh)
				sms_obj.sms
				contacts = sms_obj.contacts
				puts "#{textword} - total contacts = #{contacts.count}"
				return_contacts = []
				if contacts.kind_of?(Array) && contacts.first.kind_of?(Hash)
					return_contacts = SmsContact.bulk_create(contacts)
				end
				sms_contacts  = SmsContact.where(gift_id: nil, textword: textword.to_s)

				puts "#{textword} - sms contacts from db to gift = #{sms_contacts.count} | vs | return contacts = #{return_contacts.count}"
				sms_contacts.each do |sms_contact|
					puts "#{textword} - creating a gift for #{sms_contact.inspect}"
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

# process

# call ST-api for textwords
# loop textwords
	# call db for campaigns connect to textword
	# call ST-api for contacts for that textword
	# receive ALL contacts
	# dump all contacts into the db whether they are there or not
	# new contacts are sorted by validation textword + phone
	# goes back into database and gets contacts that dont have gift associations - even tho thats the return value of bulk_create
	# loop sms_contacts
		# run GiftCampaign.create over contacts
	# print campaign status_text to log

# CONS
# going to ST-api once per textword + once for textwords - 5-10 lookups
# saving contact records that are already in database is a lot of noise
# going into database to get the contacts when they are already return value of bulk_create







