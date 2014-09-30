require 'spec_helper'
require 'legacy_sms_contacts'

describe "Legacy Sms Contacts" do
	it "should update all sms contacts with campaign ids" do
		c1 = FactoryGirl.create :campaign
		i1 = FactoryGirl.create :campaign_item, campaign_id: c1.id, textword: "one"
		i2 = FactoryGirl.create :campaign_item, campaign_id: c1.id, textword: "two"
		
		c2 = FactoryGirl.create :campaign
		i3 = FactoryGirl.create :campaign_item, campaign_id: c2.id, textword: "three"

		s1 = FactoryGirl.create :sms_contact, textword: "one", campaign_id: nil
		s2 = FactoryGirl.create :sms_contact, textword: "two", campaign_id: nil
		s3 = FactoryGirl.create :sms_contact, textword: "three", campaign_id: nil
		s4 = FactoryGirl.create :sms_contact, textword: "four", campaign_id: nil

		LegacySmsContacts.update_campaign_ids

		s1.reload
		s2.reload
		s3.reload
		s4.reload
		s1.campaign_id.should == c1.id
		s2.campaign_id.should == c1.id
		s3.campaign_id.should == c2.id
		s4.campaign_id.should == 1
	end
	
end
