module SmsCollector

	def self.sms_promo_run
		puts "------------- Slicktext SMS Promo  -----------------"
		textword_hshs = Slicktext.textwords
		textword_hshs.each do |word_hsh|
			self.sms_promo word_hsh
		end
	end

private

	def self.sms_promo word_hsh
		textword = word_hsh["word"]

		campaign_items = CampaignItem.includes(:campaign).where(textword: textword.to_s).select { |ci| ci.live? }
		reserve_count  = campaign_items.sum(&:reserve)

		if reserve_count > 0
			self.create_gift_for_multiple_items(campaign_items, word_hsh)
		else
			puts "No live campaign Items for #{textword}"
		end
	end

	def self.create_gift_for_multiple_items items, word_hsh
		campaign_id  = items.first.campaign_id
		sms_contacts = self.slicktext_to_sms_contacts(word_hsh, campaign_id)
		sms_contacts.each do |contact|
			item_ids         = self.make_reservable_item_ids items
			campaign_item_id = item_ids.slice!(rand(item_ids.length))
			if campaign_item_id
				self.create_gift(campaign_item_id, contact)
			else
				puts "No more campaign Items for #{textword}"
			end
		end
	end

	def self.make_reservable_item_ids live_items
		reservable_items = []
		live_items.each do |item|
			item.reserve.times do
				reservable_items << item.id
			end
		end
		reservable_items
	end

	def self.create_gift campaign_item_id, sms_contact
			# associate the sms_contact with the gift
		gift_hash = { "receiver_phone" => sms_contact.phone, "payable_id" => campaign_item_id, "sms_contact" => sms_contact }
		gift = GiftCampaign.create(gift_hash)
		if gift.id.nil?
			puts "Errors = #{gift.errors.messages}"
		else
			puts "gift ID = #{gift.id}"
		end
	end

	def self.slicktext_to_sms_contacts(word_hsh, campaign_id)
		textword = word_hsh["word"]
		sms_obj = Slicktext.new(word_hsh)
		sms_obj.sms
		contacts = sms_obj.contacts

		puts "#{textword} - total contacts = #{contacts.count}"
		return_contacts = SmsContact.bulk_create(contacts, campaign_id)
		sms_contacts    = SmsContact.where(gift_id: nil, textword: textword.to_s, campaign_id: campaign_id)

		puts "#{textword} - sms contacts from db to gift = #{sms_contacts.count} | vs | return contacts = #{return_contacts.count}"
		return sms_contacts
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
