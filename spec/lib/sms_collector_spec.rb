require 'spec_helper'
require 'sms_collector'

SLICKTEXT_URL = "http://#{SLICKTEXT_PUBLIC}:#{SLICKTEXT_PRIVATE}@api.slicktext.com"
TEXTWORDS = [{"id"=>"15892", "word"=>"its on me", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-11 13:45:57", "optOuts"=>"1", "ageRequirement"=>"0"}, {"id"=>"15893", "word"=>"itsonme", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-11 13:46:16", "optOuts"=>"0", "ageRequirement"=>"0"}, {"id"=>"17429", "word"=>"no kid hungry", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-17 09:57:19", "optOuts"=>"0", "ageRequirement"=>"0"}, {"id"=>"68214", "word"=>"drinkboard", "autoReply"=>"This is a test! Go to http://bit.ly/O3eRbm to download the IOM app and receive your test campaign gift! If you're already an IOM user, check your Gift Center!", "added"=>"2014-03-12 14:32:36", "optOuts"=>"0", "ageRequirement"=>"21"}]
CONTACTS_RESPONSE =  { "contacts"=>[{"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}]}

CampaignItem.delete_all
Campaign.delete_all

describe SmsCollector do

    context "on/off" do

        it "should have an on/off switch" do

        end

        it "should not make gifts or call sicktext when camapaign hasnt started yet" do

        end

        it "should not make gifts or call sicktext if the campaign is closed" do

        end

        it "should not make gifts if the campaign_item is completed" do

        end

    end

    it "should get the textwords from slicktext" do
        textword = "itsonme"
        provider = FactoryGirl.create(:provider)
        campaign = FactoryGirl.create(:campaign)
        cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)
        contacts_route = SLICKTEXT_URL + "/v1/contacts?limit=1000&textword=15893"
        Slicktext.stub(:textwords).and_return(TEXTWORDS)
        stub_request(:get, contacts_route)
        Slicktext.any_instance.stub(:contacts).and_return(CONTACTS_RESPONSE)
        SmsCollector::sms_promo_run
        WebMock.should have_requested(:get, contacts_route).times(1)
    end

    it "creates sms_contact db records for phone numbers" do
        textword = "itsonme"
        provider = FactoryGirl.create(:provider)
        campaign = FactoryGirl.create(:campaign)
        cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)
        contacts_route = SLICKTEXT_URL + "/v1/contacts?limit=1000&textword=15893"
        Slicktext.stub(:textwords).and_return(TEXTWORDS)
        stub_request(:get, contacts_route)
        Slicktext.any_instance.stub(:resp).and_return(CONTACTS_RESPONSE)
        SmsCollector::sms_promo_run
        sms_contacts = SmsContact.all
        sms_contacts.count.should == 20
    end

    it "should create gift_campaign objs - one for each phone number" do
        textword = "itsonme"
        provider = FactoryGirl.create(:provider)
        campaign = FactoryGirl.create(:campaign)
        cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)

        route = SLICKTEXT_URL + "/v1/contacts?limit=1000&textword=#{textword}"
        stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"Basic #{SLICKTEXT_PUBLIC}"}).to_return(:status => 200, :body => @sample_response )
        SmsCollector::sms_promo("itsonme")
        gifts = Gift.where(cat: 300)
        gifts.count.should == 20
        phones = gifts.map { |g| g.receiver_phone }
        phones.uniq.count.should == 20
    end

    it "should set the sms_contact record with the gift_id when create is successful" do
        textword = "itsonme"
        provider = FactoryGirl.create(:provider)
        campaign = FactoryGirl.create(:campaign)
        cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)

        route = SLICKTEXT_URL + "/v1/contacts?limit=1000&textword=#{textword}"
        stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"Basic #{SLICKTEXT_PUBLIC}"}).to_return(:status => 200, :body => @sample_response )
        SmsCollector::sms_promo_run
        SmsContact.where.not(gift_id: nil).count.should == 20
        SmsContact.where(gift_id: nil).count.should == 0
    end

    it "should match gifts with users when phone number are attached to user accounts" do
        user = FactoryGirl.create(:user, phone: "5555555555")
        textword = "itsonme"
        provider = FactoryGirl.create(:provider)
        campaign = FactoryGirl.create(:campaign)
        cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)

        route = SLICKTEXT_URL + "/v1/contacts?limit=1000&textword=#{textword}"
        stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"Basic #{SLICKTEXT_PUBLIC}"}).to_return(:status => 200, :body => @sample_response )
        SmsCollector::sms_promo_run

        gift = Gift.where(receiver_phone: "5555555555").first
        gift.should_not be_nil
        gift.receiver.should == user
    end

    xit "should log its progress / success" do

    end

    it "should accept the word hash and create gifts" do
        stub_request(:get, "http://#{SLICKTEXT_PUBLIC}:#{SLICKTEXT_PRIVATE}@api.slicktext.com/v1/contacts?limit=1000&textword=15893").to_return(:status => 200, :body =>  @sample_response, :headers => {})
        user = FactoryGirl.create(:user, phone: "5555555555")
        textword = "itsonme"
        provider = FactoryGirl.create(:provider)
        campaign = FactoryGirl.create(:campaign)
        cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)
        word_hsh =  {"id"=>"15893", "word"=>"itsonme", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-11 13:46:16", "optOuts"=>"0", "ageRequirement"=>"0"}
        SmsCollector::sms_promo word_hsh
        gift = Gift.where(receiver_phone: "5555555555").first
        gift.should_not be_nil
        gift.receiver.should == user
    end

end