require 'spec_helper'
require 'sms_collector'
SLICKTEXT_URL = 'api.slicktext.com'
describe SmsCollector do

    before(:each) do
        CampaignItem.delete_all
        Campaign.delete_all
        @sample_response = "{\"meta\":{\"limit\":20,\"offset\":0,\"total\":2},\"links\":{\"self\":\"http://api.slicktext.com/v1/contacts/\"},\"contacts\":[{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555525555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"(555)255-5555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+3555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555552\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555445555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555225\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555551111\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555551\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5155555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+2135555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555235\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5355455555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555515\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555155555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5155555115\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555551555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555755\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5556556555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555566\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"}]}"
    end

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

    it "should get the texts from slicktext" do
        textword = "itsonme"
        provider = FactoryGirl.create(:provider)
        campaign = FactoryGirl.create(:campaign)
        cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)
        route = SLICKTEXT_URL + "/v1/contacts?limit=1000&textword=#{textword}"
        stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"Basic #{SLICKTEXT_PUBLIC}"}).to_return(:status => 200, :body => @sample_response )
        SmsCollector::sms_promo_run
        WebMock.should have_requested(:get, route).times(1)
    end

    it "creates sms_contact db records for phone numbers" do
        textword = "itsonme"
        provider = FactoryGirl.create(:provider)
        campaign = FactoryGirl.create(:campaign)
        cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, textword: textword, provider_id: provider.id)
        route = SLICKTEXT_URL + "/v1/contacts?limit=1000&textword=#{textword}"
        stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"Basic #{SLICKTEXT_PUBLIC}"}).to_return(:status => 200, :body => @sample_response )
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

end