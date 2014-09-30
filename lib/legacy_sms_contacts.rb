module LegacySmsContacts

    def self.update_campaign_ids
    	contacts = SmsContact.where(campaign_id: nil)
    	contacts.each do |contact|
    		if CampaignItem.where(textword: contact.textword).present?
    			items = CampaignItem.where(textword: contact.textword)
    			contact.update(campaign_id: items.last.campaign_id)
    		else
    			contact.update(campaign_id: 1)
    		end
    	end
    end

end
