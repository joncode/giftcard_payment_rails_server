require 'spec_helper'
require 'sms_collector'

@contact_response = [{"id"=>11111, "phone"=>"+5555555555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555525555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"(555)255-5555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+3555555555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555552",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555445555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555225",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555551111",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555551",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5155555555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+2135555555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555235",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5355455555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555515",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555155555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5155555115",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555551555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555755",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5556556555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555566",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}]
@resp = {"meta"=>{"limit"=>20, "offset"=>0, "total"=>2}, "links"=>{"self"=>"http://api.slicktext.com/v1/contacts/"}, "contacts"=>[{"id"=>11111, "phone"=>"+5555555555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555525555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"(555)255-5555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+3555555555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555552",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555445555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555225",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555551111",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555551",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5155555555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+2135555555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555235",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5355455555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555515",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555155555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5155555115",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555551555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555755",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5556556555",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "phone"=>"+5555555566",  "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}]}

SLICKTEXT_URL = "http://#{SLICKTEXT_PUBLIC}:#{SLICKTEXT_PRIVATE}@api.slicktext.com"
TEXTWORDS = [{"id"=>"15892", "word"=>"its on me", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-11 13:45:57", "optOuts"=>"1", "ageRequirement"=>"0"}, {"id"=>"15893", "word"=>"itsonme", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-11 13:46:16", "optOuts"=>"0", "ageRequirement"=>"0"}, {"id"=>"17429", "word"=>"no kid hungry", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-17 09:57:19", "optOuts"=>"0", "ageRequirement"=>"0"}, {"id"=>"68214", "word"=>"drinkboard", "autoReply"=>"This is a test! Go to http://bit.ly/O3eRbm to download the IOM app and receive your test campaign gift! If you're already an IOM user, check your Gift Center!", "added"=>"2014-03-12 14:32:36", "optOuts"=>"0", "ageRequirement"=>"21"}]
CONTACTS_RESPONSE = [{"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345839"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345323"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345589"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345109"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345722"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345752"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345844"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345178"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345385"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345978"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345378"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345912"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345453"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345266"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345644"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345637"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345309"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345790"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345349"}, {"service_id"=>"11111", "service"=>"slicktext", "textword"=>"itsonme", "subscribed_date"=>"Mon, 04 Feb 2013 21:12:45 +0000", "phone"=>"3234345595"}]

describe SmsCollector do

    before(:each) do
        CampaignItem.delete_all
        Campaign.delete_all
        SmsContact.delete_all
        @contacts_route = SLICKTEXT_URL + "/v1/contacts?limit=1000&textword=15893"
    end

    context "bug fixes" do

        it "should not break on :count" do
            textword = "itsonme"
            provider = FactoryGirl.create(:provider)
            campaign = FactoryGirl.create(:campaign)
            cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)

            Slicktext.stub(:textwords).and_return(TEXTWORDS)
            Slicktext.any_instance.stub(:sms)
            Slicktext.any_instance.should_receive(:contacts).and_return([])
            SmsCollector::sms_promo_run
        end

    end

    context :sms_promo_run do

        before(:each) do
            textword = "itsonme"
            provider = FactoryGirl.create(:provider)
            campaign = FactoryGirl.create(:campaign)
            cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)

            Slicktext.stub(:textwords).and_return(TEXTWORDS)
            stub_request(:get, @contacts_route)
            Slicktext.any_instance.stub(:contacts).and_return(CONTACTS_RESPONSE)
            SmsCollector::sms_promo_run
        end

        it "should get the textwords from slicktext" do
            # textwords_route =  SLICKTEXT_URL + "/v1/textwords?limit=1000"
            # WebMock.should have_requested(:get, textwords_route).times(1)
            WebMock.should have_requested(:get, @contacts_route).times(1)
        end

        it "creates sms_contact db records for phone numbers" do
            sms_contacts = SmsContact.all
            sms_contacts.count.should == 20
        end

        it "should create gift_campaign objs - one for each phone number" do
            sms_contacts = SmsContact.all
            sms_contacts.count.should == 20
        end

        it "should set the sms_contact record with the gift_id when create is successful" do
            SmsContact.where.not(gift_id: nil).count.should == 20
            SmsContact.where(gift_id: nil).count.should == 0
        end

        it "should match gifts with users when users sign up after gift is made" do
            number = "3234345839"
            user = FactoryGirl.create(:user, phone: number)

            gift = Gift.where(receiver_phone: number).first
            gift.should_not be_nil
            gift.receiver.should == user
        end
    end

    context "user already exists" do

        it "should match gift with user on :create" do
            number = "3234345839"
            user = FactoryGirl.create(:user, phone: number)
            CampaignItem.delete_all
            Campaign.delete_all
            SmsContact.delete_all
            textword = "itsonme"
            provider = FactoryGirl.create(:provider)
            campaign = FactoryGirl.create(:campaign)
            cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)
            Slicktext.stub(:textwords).and_return(TEXTWORDS)
            stub_request(:get, @contacts_route)
            Slicktext.any_instance.stub(:contacts).and_return(CONTACTS_RESPONSE)
            SmsCollector::sms_promo_run
            gift = Gift.where(receiver_phone: number).first
            gift.should_not be_nil
            gift.receiver.should == user
        end
    end

end
