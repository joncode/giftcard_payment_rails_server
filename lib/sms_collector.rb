module sms_collector

	def get_contacts textword
		sms_data = SlicktextGateway.new(textword: textword, limit: 1000)
		contact_params_array = sms_data.contacts
		if sms_data.status == 200
			contact_params_array.each do |contact_params|
				Sms.create(contact_params)
			end
			campaign_items = CampaignItem.all
			Sms.where(gift_id:nil).each do |sms|
				campaign_item = campaign_items.where(textword: sms.textword).first
				gift_hash = {receiver_name: "#{campaign_item.name} gift", receiver_phone: sms.phone, payable_id: campaign_item.id}
				GiftCampaign.create(gift_hash)
			end
			success "#{contact_params_array.count} new contacts added to SMS database"
		else
			fail "connection with sms gateway failed."
		end
	end

end




gifts = gifts with no id
campaign_hash = get_camps (smss)


def get_camps smss
	{ text => campaign_item_object }
end

create_gift_camp smss, campaign_hsh
emd